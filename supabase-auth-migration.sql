-- ═══════════════════════════════════════════════════════════════════════════
-- AffiLinks CRM — Real authentication + per-pipeline permissions migration
-- ═══════════════════════════════════════════════════════════════════════════
--
-- Run this in the Supabase SQL editor. It is split into STAGE 1 and STAGE 3,
-- matching the rollout sequence in the implementation plan — run them at
-- DIFFERENT times, not both back-to-back:
--
--   STAGE 1 (run now, zero risk)   — creates the new tables/functions only.
--                                     Every existing table is untouched and
--                                     stays exactly as open as it is today.
--
--   STAGE 2 (no SQL — this is a code deploy) — create every teammate's login
--     in Supabase Dashboard → Authentication → Users (NOT self-signup), then
--     also go to Authentication → Settings and turn OFF "Allow new users to
--     sign up". Confirm each teammate can log in with the new LoginScreen.
--     Deploy the updated index.html. Data access is still fully open at this
--     point — only login is now required.
--
--   STAGE 3 (run after Stage 2 is confirmed working) — flips on Row Level
--     Security for real. BEFORE running this block: go to the app's new
--     Settings → Team Access panel (as an admin) and grant every current
--     teammate can_view + can_edit on every section they actually use today,
--     so enabling RLS doesn't also silently change who can do what. Then run
--     the STAGE 3 block below ONE TABLE AT A TIME (copy just one table's
--     statements, run it, smoke-test that pipeline in the app, then move to
--     the next) rather than pasting the whole block at once. If a table's
--     policy is wrong, the instant rollback for JUST that table is:
--       ALTER TABLE <that_table> DISABLE ROW LEVEL SECURITY;
--
--   STAGE 4 (no SQL) — once Stage 3 is stable, the admin narrows individual
--     teammates' access below "everything" via the Team Access panel,
--     one person at a time. Pure data changes, no migration needed.
--
-- ═══════════════════════════════════════════════════════════════════════════


-- ═══════════════════════════════════════════════════════════════════════════
-- STAGE 1 — new tables, auto-profile trigger, permission helper functions
-- ═══════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS user_profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text NOT NULL,
  name text,
  is_admin boolean NOT NULL DEFAULT false,
  is_active boolean NOT NULL DEFAULT true,  -- instant kill-switch for an offboarded teammate
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS user_permissions (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  section text NOT NULL CHECK (section IN
    ('allcontacts','pipeline','clients','contacts','freelance',
     'coldcalling','emailcampaign','paidleads','clientpayments','expenses')),
  can_view boolean NOT NULL DEFAULT true,
  can_edit boolean NOT NULL DEFAULT false,
  UNIQUE(user_id, section)
);

-- Auto-create a profile row whenever an account is added in the Supabase dashboard
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email) VALUES (new.id, new.email)
  ON CONFLICT (id) DO NOTHING;
  RETURN new;
END; $$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Permission-check helpers. SECURITY DEFINER is deliberate: it lets these
-- functions read user_profiles/user_permissions without those tables' own
-- RLS being re-evaluated inside a policy that's itself being evaluated
-- (avoids a recursive-RLS deadlock).

CREATE OR REPLACE FUNCTION public.is_admin_user()
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT COALESCE(is_admin, false) FROM user_profiles WHERE id = auth.uid() AND is_active;
$$;

CREATE OR REPLACE FUNCTION public.has_section_access(p_section text, p_need_edit boolean DEFAULT false)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT is_admin_user() OR EXISTS (
    SELECT 1 FROM user_permissions up JOIN user_profiles pr ON pr.id = up.user_id
    WHERE up.user_id = auth.uid() AND pr.is_active AND up.section = p_section
      AND (up.can_view OR up.can_edit) AND (NOT p_need_edit OR up.can_edit)
  );
$$;

CREATE OR REPLACE FUNCTION public.has_any_section_access(p_sections text[], p_need_edit boolean DEFAULT false)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT is_admin_user() OR EXISTS (
    SELECT 1 FROM user_permissions up JOIN user_profiles pr ON pr.id = up.user_id
    WHERE up.user_id = auth.uid() AND pr.is_active AND up.section = ANY(p_sections)
      AND (up.can_view OR up.can_edit) AND (NOT p_need_edit OR up.can_edit)
  );
$$;

-- RLS on the new tables themselves (safe to enable immediately — these are
-- brand-new empty tables, not part of the "existing app" that must keep
-- working during Stage 1/2).
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS user_profiles_select ON user_profiles;
CREATE POLICY user_profiles_select ON user_profiles FOR SELECT TO authenticated
  USING (id = auth.uid() OR is_admin_user());
DROP POLICY IF EXISTS user_profiles_update ON user_profiles;
CREATE POLICY user_profiles_update ON user_profiles FOR UPDATE TO authenticated
  USING (is_admin_user()) WITH CHECK (is_admin_user());

ALTER TABLE user_permissions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS user_permissions_select ON user_permissions;
CREATE POLICY user_permissions_select ON user_permissions FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR is_admin_user());
DROP POLICY IF EXISTS user_permissions_write ON user_permissions;
CREATE POLICY user_permissions_write ON user_permissions FOR ALL TO authenticated
  USING (is_admin_user()) WITH CHECK (is_admin_user());

GRANT SELECT, UPDATE ON user_profiles TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON user_permissions TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE user_permissions_id_seq TO authenticated;

-- After running this block: sign up your first teammate via Supabase
-- Dashboard → Authentication → Users → Add user. Then run, once:
--   UPDATE user_profiles SET is_admin = true WHERE email = 'you@yourcompany.com';
-- That's the only manually-flagged admin; they can promote/demote others
-- later from the app's Team Access panel once Stage 2 code is live.


-- ═══════════════════════════════════════════════════════════════════════════
-- STAGE 3 — enable RLS on every existing table (run ONE TABLE AT A TIME,
-- only after mirroring current access into user_permissions for everyone —
-- see the note at the top of this file)
-- ═══════════════════════════════════════════════════════════════════════════

-- ── leads (LinkedIn Pipeline) ── also read by All Contacts ──────────────────
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS leads_select ON leads;
CREATE POLICY leads_select ON leads FOR SELECT TO authenticated
  USING (has_any_section_access(ARRAY['contacts','allcontacts'], false));
DROP POLICY IF EXISTS leads_insert ON leads;
CREATE POLICY leads_insert ON leads FOR INSERT TO authenticated
  WITH CHECK (has_section_access('contacts', true));
DROP POLICY IF EXISTS leads_update ON leads;
CREATE POLICY leads_update ON leads FOR UPDATE TO authenticated
  USING (has_section_access('contacts', true)) WITH CHECK (has_section_access('contacts', true));
DROP POLICY IF EXISTS leads_delete ON leads;
CREATE POLICY leads_delete ON leads FOR DELETE TO authenticated
  USING (has_section_access('contacts', true));

-- ── templates (shared: LinkedIn + Freelance) ─────────────────────────────────
ALTER TABLE templates ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS templates_select ON templates;
CREATE POLICY templates_select ON templates FOR SELECT TO authenticated
  USING (has_any_section_access(ARRAY['contacts','freelance'], false));
DROP POLICY IF EXISTS templates_insert ON templates;
CREATE POLICY templates_insert ON templates FOR INSERT TO authenticated
  WITH CHECK (has_any_section_access(ARRAY['contacts','freelance'], true));
DROP POLICY IF EXISTS templates_update ON templates;
CREATE POLICY templates_update ON templates FOR UPDATE TO authenticated
  USING (has_any_section_access(ARRAY['contacts','freelance'], true))
  WITH CHECK (has_any_section_access(ARRAY['contacts','freelance'], true));
DROP POLICY IF EXISTS templates_delete ON templates;
CREATE POLICY templates_delete ON templates FOR DELETE TO authenticated
  USING (has_any_section_access(ARRAY['contacts','freelance'], true));

-- ── hot_pipeline (fan-in target — 5 pipelines insert into this on "Won") ────
-- SELECT is deliberately widened to every section allowed to INSERT: because
-- every write in this app reads its own response body to update the UI
-- (Prefer: return=representation), a SELECT policy narrower than the INSERT
-- policy makes a successful write look like a silent failure on screen.
ALTER TABLE hot_pipeline ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS hot_pipeline_select ON hot_pipeline;
CREATE POLICY hot_pipeline_select ON hot_pipeline FOR SELECT TO authenticated
  USING (has_any_section_access(ARRAY['pipeline','clients','clientpayments','allcontacts',
                                       'contacts','freelance','coldcalling','emailcampaign','paidleads'], false));
DROP POLICY IF EXISTS hot_pipeline_insert ON hot_pipeline;
CREATE POLICY hot_pipeline_insert ON hot_pipeline FOR INSERT TO authenticated
  WITH CHECK (has_any_section_access(ARRAY['pipeline','contacts','freelance','coldcalling','emailcampaign','paidleads'], true));
DROP POLICY IF EXISTS hot_pipeline_update ON hot_pipeline;
CREATE POLICY hot_pipeline_update ON hot_pipeline FOR UPDATE TO authenticated
  USING (has_section_access('pipeline', true)) WITH CHECK (has_section_access('pipeline', true));
DROP POLICY IF EXISTS hot_pipeline_delete ON hot_pipeline;
CREATE POLICY hot_pipeline_delete ON hot_pipeline FOR DELETE TO authenticated
  USING (has_section_access('pipeline', true));

-- ── active_clients / active_clients_monthly_status ── also read by Client Payments ──
ALTER TABLE active_clients ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS active_clients_select ON active_clients;
CREATE POLICY active_clients_select ON active_clients FOR SELECT TO authenticated
  USING (has_any_section_access(ARRAY['clients','clientpayments'], false));
DROP POLICY IF EXISTS active_clients_insert ON active_clients;
CREATE POLICY active_clients_insert ON active_clients FOR INSERT TO authenticated
  WITH CHECK (has_section_access('clients', true));
DROP POLICY IF EXISTS active_clients_update ON active_clients;
CREATE POLICY active_clients_update ON active_clients FOR UPDATE TO authenticated
  USING (has_section_access('clients', true)) WITH CHECK (has_section_access('clients', true));
DROP POLICY IF EXISTS active_clients_delete ON active_clients;
CREATE POLICY active_clients_delete ON active_clients FOR DELETE TO authenticated
  USING (has_section_access('clients', true));

ALTER TABLE active_clients_monthly_status ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS acms_select ON active_clients_monthly_status;
CREATE POLICY acms_select ON active_clients_monthly_status FOR SELECT TO authenticated
  USING (has_any_section_access(ARRAY['clients','clientpayments'], false));
DROP POLICY IF EXISTS acms_insert ON active_clients_monthly_status;
CREATE POLICY acms_insert ON active_clients_monthly_status FOR INSERT TO authenticated
  WITH CHECK (has_section_access('clients', true));
DROP POLICY IF EXISTS acms_update ON active_clients_monthly_status;
CREATE POLICY acms_update ON active_clients_monthly_status FOR UPDATE TO authenticated
  USING (has_section_access('clients', true)) WITH CHECK (has_section_access('clients', true));
DROP POLICY IF EXISTS acms_delete ON active_clients_monthly_status;
CREATE POLICY acms_delete ON active_clients_monthly_status FOR DELETE TO authenticated
  USING (has_section_access('clients', true));

-- ── freelance_pipeline ── also read by All Contacts ─────────────────────────
ALTER TABLE freelance_pipeline ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS freelance_pipeline_select ON freelance_pipeline;
CREATE POLICY freelance_pipeline_select ON freelance_pipeline FOR SELECT TO authenticated
  USING (has_any_section_access(ARRAY['freelance','allcontacts'], false));
DROP POLICY IF EXISTS freelance_pipeline_insert ON freelance_pipeline;
CREATE POLICY freelance_pipeline_insert ON freelance_pipeline FOR INSERT TO authenticated
  WITH CHECK (has_section_access('freelance', true));
DROP POLICY IF EXISTS freelance_pipeline_update ON freelance_pipeline;
CREATE POLICY freelance_pipeline_update ON freelance_pipeline FOR UPDATE TO authenticated
  USING (has_section_access('freelance', true)) WITH CHECK (has_section_access('freelance', true));
DROP POLICY IF EXISTS freelance_pipeline_delete ON freelance_pipeline;
CREATE POLICY freelance_pipeline_delete ON freelance_pipeline FOR DELETE TO authenticated
  USING (has_section_access('freelance', true));

-- ── cold_calling ── also read by All Contacts ────────────────────────────────
ALTER TABLE cold_calling ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS cold_calling_select ON cold_calling;
CREATE POLICY cold_calling_select ON cold_calling FOR SELECT TO authenticated
  USING (has_any_section_access(ARRAY['coldcalling','allcontacts'], false));
DROP POLICY IF EXISTS cold_calling_insert ON cold_calling;
CREATE POLICY cold_calling_insert ON cold_calling FOR INSERT TO authenticated
  WITH CHECK (has_section_access('coldcalling', true));
DROP POLICY IF EXISTS cold_calling_update ON cold_calling;
CREATE POLICY cold_calling_update ON cold_calling FOR UPDATE TO authenticated
  USING (has_section_access('coldcalling', true)) WITH CHECK (has_section_access('coldcalling', true));
DROP POLICY IF EXISTS cold_calling_delete ON cold_calling;
CREATE POLICY cold_calling_delete ON cold_calling FOR DELETE TO authenticated
  USING (has_section_access('coldcalling', true));

-- ── email_campaign ── also read by All Contacts ──────────────────────────────
ALTER TABLE email_campaign ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS email_campaign_select ON email_campaign;
CREATE POLICY email_campaign_select ON email_campaign FOR SELECT TO authenticated
  USING (has_any_section_access(ARRAY['emailcampaign','allcontacts'], false));
DROP POLICY IF EXISTS email_campaign_insert ON email_campaign;
CREATE POLICY email_campaign_insert ON email_campaign FOR INSERT TO authenticated
  WITH CHECK (has_section_access('emailcampaign', true));
DROP POLICY IF EXISTS email_campaign_update ON email_campaign;
CREATE POLICY email_campaign_update ON email_campaign FOR UPDATE TO authenticated
  USING (has_section_access('emailcampaign', true)) WITH CHECK (has_section_access('emailcampaign', true));
DROP POLICY IF EXISTS email_campaign_delete ON email_campaign;
CREATE POLICY email_campaign_delete ON email_campaign FOR DELETE TO authenticated
  USING (has_section_access('emailcampaign', true));

-- ── ec_templates (owned solely by Email Campaign) ────────────────────────────
ALTER TABLE ec_templates ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS ec_templates_select ON ec_templates;
CREATE POLICY ec_templates_select ON ec_templates FOR SELECT TO authenticated
  USING (has_section_access('emailcampaign', false));
DROP POLICY IF EXISTS ec_templates_insert ON ec_templates;
CREATE POLICY ec_templates_insert ON ec_templates FOR INSERT TO authenticated
  WITH CHECK (has_section_access('emailcampaign', true));
DROP POLICY IF EXISTS ec_templates_update ON ec_templates;
CREATE POLICY ec_templates_update ON ec_templates FOR UPDATE TO authenticated
  USING (has_section_access('emailcampaign', true)) WITH CHECK (has_section_access('emailcampaign', true));
DROP POLICY IF EXISTS ec_templates_delete ON ec_templates;
CREATE POLICY ec_templates_delete ON ec_templates FOR DELETE TO authenticated
  USING (has_section_access('emailcampaign', true));

-- ── paid_leads ── also read by All Contacts (this table was previously
-- missing from the README's RLS-disable instructions entirely) ──────────────
ALTER TABLE paid_leads ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS paid_leads_select ON paid_leads;
CREATE POLICY paid_leads_select ON paid_leads FOR SELECT TO authenticated
  USING (has_any_section_access(ARRAY['paidleads','allcontacts'], false));
DROP POLICY IF EXISTS paid_leads_insert ON paid_leads;
CREATE POLICY paid_leads_insert ON paid_leads FOR INSERT TO authenticated
  WITH CHECK (has_section_access('paidleads', true));
DROP POLICY IF EXISTS paid_leads_update ON paid_leads;
CREATE POLICY paid_leads_update ON paid_leads FOR UPDATE TO authenticated
  USING (has_section_access('paidleads', true)) WITH CHECK (has_section_access('paidleads', true));
DROP POLICY IF EXISTS paid_leads_delete ON paid_leads;
CREATE POLICY paid_leads_delete ON paid_leads FOR DELETE TO authenticated
  USING (has_section_access('paidleads', true));

-- ── client_payments ── owned by Client Payments ──────────────────────────────
ALTER TABLE client_payments ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS client_payments_select ON client_payments;
CREATE POLICY client_payments_select ON client_payments FOR SELECT TO authenticated
  USING (has_section_access('clientpayments', false));
DROP POLICY IF EXISTS client_payments_insert ON client_payments;
CREATE POLICY client_payments_insert ON client_payments FOR INSERT TO authenticated
  WITH CHECK (has_section_access('clientpayments', true));
DROP POLICY IF EXISTS client_payments_update ON client_payments;
CREATE POLICY client_payments_update ON client_payments FOR UPDATE TO authenticated
  USING (has_section_access('clientpayments', true)) WITH CHECK (has_section_access('clientpayments', true));
DROP POLICY IF EXISTS client_payments_delete ON client_payments;
CREATE POLICY client_payments_delete ON client_payments FOR DELETE TO authenticated
  USING (has_section_access('clientpayments', true));

-- ── payment_entries ── also read by Balance Sheet (expenses) for its Revenue box ──
ALTER TABLE payment_entries ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS payment_entries_select ON payment_entries;
CREATE POLICY payment_entries_select ON payment_entries FOR SELECT TO authenticated
  USING (has_any_section_access(ARRAY['clientpayments','expenses'], false));
DROP POLICY IF EXISTS payment_entries_insert ON payment_entries;
CREATE POLICY payment_entries_insert ON payment_entries FOR INSERT TO authenticated
  WITH CHECK (has_section_access('clientpayments', true));
DROP POLICY IF EXISTS payment_entries_update ON payment_entries;
CREATE POLICY payment_entries_update ON payment_entries FOR UPDATE TO authenticated
  USING (has_section_access('clientpayments', true)) WITH CHECK (has_section_access('clientpayments', true));
DROP POLICY IF EXISTS payment_entries_delete ON payment_entries;
CREATE POLICY payment_entries_delete ON payment_entries FOR DELETE TO authenticated
  USING (has_section_access('clientpayments', true));

-- ── expense_sheets (Balance Sheet) ───────────────────────────────────────────
ALTER TABLE expense_sheets ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS expense_sheets_select ON expense_sheets;
CREATE POLICY expense_sheets_select ON expense_sheets FOR SELECT TO authenticated
  USING (has_section_access('expenses', false));
DROP POLICY IF EXISTS expense_sheets_insert ON expense_sheets;
CREATE POLICY expense_sheets_insert ON expense_sheets FOR INSERT TO authenticated
  WITH CHECK (has_section_access('expenses', true));
DROP POLICY IF EXISTS expense_sheets_update ON expense_sheets;
CREATE POLICY expense_sheets_update ON expense_sheets FOR UPDATE TO authenticated
  USING (has_section_access('expenses', true)) WITH CHECK (has_section_access('expenses', true));
DROP POLICY IF EXISTS expense_sheets_delete ON expense_sheets;
CREATE POLICY expense_sheets_delete ON expense_sheets FOR DELETE TO authenticated
  USING (has_section_access('expenses', true));

-- ── activity_log (shared read+write: LinkedIn, Freelance, Cold Calling, Email Campaign) ──
ALTER TABLE activity_log ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS activity_log_select ON activity_log;
CREATE POLICY activity_log_select ON activity_log FOR SELECT TO authenticated
  USING (has_any_section_access(ARRAY['contacts','freelance','coldcalling','emailcampaign'], false));
DROP POLICY IF EXISTS activity_log_insert ON activity_log;
CREATE POLICY activity_log_insert ON activity_log FOR INSERT TO authenticated
  WITH CHECK (has_any_section_access(ARRAY['contacts','freelance','coldcalling','emailcampaign'], true));
DROP POLICY IF EXISTS activity_log_delete ON activity_log;
CREATE POLICY activity_log_delete ON activity_log FOR DELETE TO authenticated
  USING (has_any_section_access(ARRAY['contacts','freelance','coldcalling','emailcampaign'], true));

-- ── base GRANTs — policies do nothing without these. Supabase's default
-- template usually already grants these to `authenticated`, but confirm
-- during rollout (run \dp <table> in the SQL editor, or just re-run this —
-- GRANT is idempotent) ────────────────────────────────────────────────────
GRANT SELECT, INSERT, UPDATE, DELETE ON
  leads, templates, hot_pipeline, active_clients, active_clients_monthly_status,
  freelance_pipeline, cold_calling, email_campaign, ec_templates, paid_leads,
  client_payments, payment_entries, expense_sheets, activity_log
  TO authenticated;

-- Once Stage 3 is fully stable across every table above, run this as
-- defense-in-depth (nothing should legitimately write with just the anon
-- key anymore):
--   REVOKE INSERT, UPDATE, DELETE ON
--     leads, templates, hot_pipeline, active_clients, active_clients_monthly_status,
--     freelance_pipeline, cold_calling, email_campaign, ec_templates, paid_leads,
--     client_payments, payment_entries, expense_sheets, activity_log,
--     user_profiles, user_permissions
--     FROM anon;

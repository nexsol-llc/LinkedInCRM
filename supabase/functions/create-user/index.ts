// Supabase Edge Function: create-user
//
// Lets an admin create a new teammate's login (email + password) from inside
// the CRM's Team Access panel, without ever exposing the service_role key to
// the browser. The service_role key only exists here, server-side, injected
// automatically by Supabase at deploy time — never put it in index.html or
// commit it anywhere.
//
// Deploy with the Supabase CLI:
//   supabase login
//   supabase link --project-ref iededwksmveomkrhofzu
//   supabase functions deploy create-user
//
// SUPABASE_URL / SUPABASE_ANON_KEY / SUPABASE_SERVICE_ROLE_KEY are provided
// automatically to every Edge Function — no manual secret-setting needed.

import { createClient } from "npm:@supabase/supabase-js@2";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS_HEADERS });
  if (req.method !== "POST") return json({ error: "Method not allowed." }, 405);

  try {
    const authHeader = req.headers.get("Authorization") || "";
    const callerToken = authHeader.replace(/^Bearer\s+/i, "");
    if (!callerToken) return json({ error: "Missing authorization." }, 401);

    const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
    const ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;
    const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    // Client scoped to the caller's own token, just to find out who they are.
    const callerClient = createClient(SUPABASE_URL, ANON_KEY, {
      global: { headers: { Authorization: `Bearer ${callerToken}` } },
    });
    const { data: callerData, error: callerErr } = await callerClient.auth.getUser();
    if (callerErr || !callerData?.user) return json({ error: "Invalid session." }, 401);

    // Admin-privileged client — only ever used server-side, inside this function.
    const adminClient = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

    // Confirm the caller is actually an active admin before doing anything.
    const { data: callerProfile, error: profileErr } = await adminClient
      .from("user_profiles")
      .select("is_admin, is_active")
      .eq("id", callerData.user.id)
      .maybeSingle();
    if (profileErr || !callerProfile?.is_admin || !callerProfile?.is_active) {
      return json({ error: "Only active admins can create users." }, 403);
    }

    const body = await req.json().catch(() => ({}));
    const email = String(body.email || "").trim();
    const password = String(body.password || "");
    const name = String(body.name || "").trim();
    if (!email || password.length < 8) {
      return json({ error: "Email and a password of at least 8 characters are required." }, 400);
    }

    const { data: created, error: createErr } = await adminClient.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: name ? { name } : undefined,
    });
    if (createErr) return json({ error: createErr.message }, 400);

    // The on_auth_user_created trigger already inserted a user_profiles row
    // (id + email); fill in the display name if one was given.
    if (name && created?.user?.id) {
      await adminClient.from("user_profiles").update({ name }).eq("id", created.user.id);
    }

    return json({ id: created.user.id, email: created.user.email });
  } catch (e) {
    return json({ error: String((e as Error)?.message || e) }, 500);
  }
});

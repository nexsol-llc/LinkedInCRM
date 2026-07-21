# 🚀 AffiLinks.io — Full CRM

> A powerful, production-ready sales CRM with multi-pipeline management, cold calling, email outreach, freelance tracking, and team activity logging. Built with React, powered by Supabase, and deployed on Vercel.

**Live URL:** [https://linked-crm.vercel.app](https://linked-crm.vercel.app)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Database Setup](#database-setup)
- [Getting Started](#getting-started)
- [Navigation](#navigation)
- [Pipelines](#pipelines)
  - [LinkedIn Pipeline](#linkedin-pipeline)
  - [Hot Pipeline](#hot-pipeline)
  - [Freelance Pipeline](#freelance-pipeline)
  - [Cold Calling](#cold-calling)
  - [Email Campaign](#email-campaign)
  - [Paid Leads](#paid-leads)
  - [Active Clients](#active-clients)
  - [Client Payments](#client-payments)
  - [Balance Sheet](#balance-sheet)
  - [All Contacts](#all-contacts)
- [Activity Log](#activity-log)
- [CSV Import & Export](#csv-import--export)
- [Stages Reference](#stages-reference)
- [Tags](#tags)
- [Notifications & Reminders](#notifications--reminders)
- [Deployment](#deployment)
- [Security](#security)

---

## 🌟 Overview

AffiLinks.io is a custom-built CRM designed for **sales and outreach teams**. It features six lead pipelines plus client lifecycle and payments management, all behind a single password-protected dashboard with a common sidebar navigation:

| Pipeline | Purpose |
|---|---|
| 🔥 Hot Pipeline | Multi-channel sales tracker (Fiverr, Upwork, LinkedIn, Email, WhatsApp, Calling, Paid Leads) |
| 💼 LinkedIn Pipeline | LinkedIn outreach management with full follow-up tracking |
| 🧩 Freelance Pipeline | Freelance platform lead tracker (Fiverr, Upwork, Freelancer) |
| 📞 Cold Calling | Phone outreach tracker with call status and appointment booking |
| ✉️ Email Campaign | Email outreach pipeline with connected/appointment stages |
| 💵 Paid Leads | Paid ad lead tracker (Meta Ads, Google Ads, LinkedIn Ads) |
| 👥 Active Clients | Monthly client lifecycle manager with revenue analytics |
| 💳 Client Payments | Contract & installment tracker with payment status and calendar |

All data is stored in **Supabase (PostgreSQL)** and syncs across any device in real time.

---

## ✨ Features

### General
- 🔐 Single password protection
- 💾 Real-time sync via Supabase — works on any device
- 📥 CSV Import with duplicate detection
- ⬇️ CSV Export of all contacts
- 🔔 Bell notification with follow-up reminders
- 🏷️ Tags & labels system
- 📊 Analytics tab on every pipeline
- 📋 **Activity Log** tab on every pipeline — log daily team activity with calendar and export

### LinkedIn Pipeline
- 🗂️ Kanban board with drag & drop
- 👥 Contacts table with search & filter
- 📅 Calendar with follow-up reminders
- ✉️ Message templates
- 💰 Deal closing with amount, date & contract
- 🔁 Follow-up history & attempt tracking
- 🔔 Overdue reminders with Review popup
- 🔍 Sales Navigator CSV import
- 🔗 Auto-clone to Hot Pipeline on Won

### Hot Pipeline
- 🔥 10-stage Kanban (Fiverr → Won → Loss)
- 💰 Per-channel sales stat boxes
- 📅 Month picker for historical snapshots
- 📈 Monthly Sales comparison widget
- 📊 Multi-month insight chart
- 🔍 Live search across all cards

### Freelance Pipeline
- 🧩 7-stage Kanban (Fiverr, Upwork, Freelancer → WON)
- 📌 Source filtering by platform
- 📅 Follow-up scheduling & history
- ✉️ Message templates
- 📊 Platform analytics (leads by source + win rate)

### Cold Calling
- 📞 10-stage Kanban with call status tracking
- 📅 Appointment booking flow
- 🚫 DND (Do Not Disturb) stage
- 🔔 Overdue reminders for follow-ups and appointments
- 📊 Call status breakdown analytics

### Email Campaign
- ✉️ 10-stage Kanban (Awin Leads → Won)
- 📅 Appointment tracking
- 🚫 DND stage
- 📊 Stage and campaign analytics

### Paid Leads
- 💵 9-stage Kanban (Meta Ads, Google Ads, LinkedIn Ads → WON)
- 📌 Source filtering by ad platform
- 📅 Follow-up, appointment & trash flows
- 🔍 Live search across all cards

### Active Clients
- 👥 Three-column Kanban: Active, Winning, Lost
- 🔄 Auto-roll on new month
- 🏆 Winning Clients auto-synced from Hot Pipeline Won
- 💰 Revenue tracking with comparison graph (current vs previous month)
- 📋 YTD Active Projects & Lost Projects with CSV export

### Client Payments
- 📅 Month picker (supports future months) with 6 revenue stat boxes
- 📄 Client Contracts tab — payment source, condition & remarks per contract
- 💳 Payment Status tab — log installments (Pending / Paid / Balance Lost) with PKR received tracking
- 🗓️ Payment Calendar tab
- 🔄 Auto-rolls unpaid "Pending" entries into the current month
- Pulls contracts automatically from Active Clients + Hot Pipeline "Won" deals

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Frontend | React 18 (via CDN + Babel standalone) |
| Database | Supabase (PostgreSQL) |
| Hosting | Vercel |
| Styling | Inline CSS (no frameworks) |
| Auth | Password-based (client-side) |

---

## 🗄️ Database Setup

### Supabase Project
- **Project ID:** `iededwksmveomkrhofzu`
- **Project URL:** `https://iededwksmveomkrhofzu.supabase.co`

### Tables

#### `leads` — LinkedIn Pipeline contacts
```sql
CREATE TABLE leads (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  first_name text,
  last_name text,
  linkedin_url text,
  website text,
  industry text,
  affiliate_network text,
  email text,
  phone text,
  stage text DEFAULT 'Cold',
  tags text[] DEFAULT '{}',
  follow_up jsonb,
  deal jsonb,
  follow_up_history jsonb[] DEFAULT '{}',
  created_at timestamptz DEFAULT now()
);
```

#### `templates` — Message templates (shared across pipelines)
```sql
CREATE TABLE templates (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name text,
  body text,
  created_at timestamptz DEFAULT now()
);
```

#### `hot_pipeline` — Hot Pipeline contacts
```sql
CREATE TABLE hot_pipeline (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  first_name text,
  last_name text,
  linkedin_url text,
  website text,
  industry text,
  email text,
  account_name text,
  source text,
  stage text DEFAULT 'Fiverr',
  sale_value numeric DEFAULT 0,
  tags text[] DEFAULT '{}',
  follow_up jsonb,
  deal jsonb,
  follow_up_history jsonb[] DEFAULT '{}',
  won_at timestamptz,
  created_at timestamptz DEFAULT now()
);
```

#### `freelance_pipeline` — Freelance Pipeline contacts
```sql
CREATE TABLE freelance_pipeline (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  first_name text,
  last_name text,
  email text,
  phone text,
  linkedin_url text,
  website text,
  company_name text,
  project_type text,
  source text DEFAULT 'Fiverr',
  stage text DEFAULT 'Fiverr',
  sale_value numeric DEFAULT 0,
  tags text[] DEFAULT '{}',
  follow_up jsonb,
  deal jsonb,
  follow_up_history jsonb[] DEFAULT '{}',
  won_at timestamptz,
  created_at timestamptz DEFAULT now()
);
```

#### `cold_calling` — Cold Calling leads
```sql
CREATE TABLE cold_calling (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  first_name text,
  last_name text,
  email text,
  phone text,
  linkedin_url text,
  website text,
  company text,
  industry text,
  source text,
  stage text DEFAULT 'Awin Leads',
  call_status text,
  sale_value numeric DEFAULT 0,
  tags text[] DEFAULT '{}',
  follow_up jsonb,
  appointment jsonb,
  deal jsonb,
  follow_up_history jsonb[] DEFAULT '{}',
  created_at timestamptz DEFAULT now()
);
```

#### `email_campaign` — Email Campaign leads
```sql
CREATE TABLE email_campaign (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  first_name text,
  last_name text,
  email text,
  phone text,
  linkedin_url text,
  website text,
  company text,
  industry text,
  source text,
  stage text DEFAULT 'Awin Leads',
  sale_value numeric DEFAULT 0,
  tags text[] DEFAULT '{}',
  follow_up jsonb,
  appointment jsonb,
  deal jsonb,
  follow_up_history jsonb[] DEFAULT '{}',
  created_at timestamptz DEFAULT now()
);
```

#### `paid_leads` — Paid Leads (Meta/Google/LinkedIn Ads) contacts
```sql
CREATE TABLE paid_leads (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  first_name text,
  last_name text,
  company_name text,
  website text,
  industry text,
  region text,
  phone_number text,
  email text,
  linkedin_url text,
  trending_product text,
  affiliate_network text,
  source text,
  stage text DEFAULT 'Meta Ads',
  follow_up jsonb,
  follow_up_history jsonb[] DEFAULT '{}',
  connected jsonb,
  appointment jsonb,
  appointment_history jsonb[] DEFAULT '{}',
  lost jsonb,
  trash jsonb,
  deal jsonb,
  created_at timestamptz DEFAULT now()
);
```

#### `active_clients` — Active Client records
```sql
CREATE TABLE active_clients (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  first_name text,
  last_name text,
  company text,
  email text,
  phone text,
  contract_terms text,
  revenue numeric DEFAULT 0,
  source text DEFAULT 'manual',
  hot_pipeline_id bigint REFERENCES hot_pipeline(id),
  created_at timestamptz DEFAULT now()
);
```

#### `active_clients_monthly_status` — Per-month status tracking
```sql
CREATE TABLE active_clients_monthly_status (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  client_id bigint REFERENCES active_clients(id),
  month text,        -- format: 'YYYY-MM'
  status text,       -- 'active' | 'lost'
  reason text,       -- loss reason (optional)
  created_at timestamptz DEFAULT now(),
  UNIQUE(client_id, month)
);
```

#### `client_payments` — Contract-level payment metadata
```sql
CREATE TABLE client_payments (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  source_type text,        -- 'active' | 'winning'
  source_id bigint,        -- references active_clients.id or hot_pipeline.id
  client_name text,
  company_name text,
  payment_source text,
  payment_condition text DEFAULT 'Before Service',
  contract_date date,
  amount_closed numeric DEFAULT 0,
  remarks text,
  created_at timestamptz DEFAULT now()
);
```

#### `payment_entries` — Individual payment installments
```sql
CREATE TABLE payment_entries (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  contract_key text,       -- e.g. 'ac_12' or 'hp_34'
  client_name text,
  company_name text,
  scheduled_date date,
  amount numeric DEFAULT 0,
  status text DEFAULT 'Pending',  -- 'Pending' | 'Paid' | 'Balance Lost'
  received_pkr numeric DEFAULT 0,
  received_from text,
  month text,               -- format: 'YYYY-MM'
  created_at timestamptz DEFAULT now()
);
```

#### `expense_sheets` — Expense spreadsheets (one or more sheets per month)
```sql
CREATE TABLE expense_sheets (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  month text NOT NULL,               -- format: 'YYYY-MM' — not unique; a month can have multiple sheets
  name text,                         -- sheet display name, e.g. 'July 2026', 'Sheet 2', 'Travel'
  cells jsonb DEFAULT '{}'::jsonb,   -- { "A1": "raw value or =formula", "B2": "250", ... }
  boxes jsonb DEFAULT '[]'::jsonb,   -- [{ "id": "...", "label": "Total Spend", "formula": "=SUM(B1:B30)" }]
  styles jsonb DEFAULT '{}'::jsonb,  -- { "A1": { "bold": true, "color": "#fff", "bg": "#222" } }
  merges jsonb DEFAULT '[]'::jsonb,  -- [{ "start": "E1", "end": "F1" }]
  dropdowns jsonb DEFAULT '{}'::jsonb, -- { "G1": ["Food","Transport","Rent"] }
  total_expenses_formula text DEFAULT '', -- built-in "Total Expenses" box formula for this sheet, e.g. '=SUM(B2:B31)'
  row_count int DEFAULT 30,
  created_at timestamptz DEFAULT now()
);
```

#### `activity_log` — Team daily activity log
```sql
CREATE TABLE activity_log (
  id bigserial PRIMARY KEY,
  pipeline text NOT NULL,
  date date NOT NULL,
  name text NOT NULL,
  activity text NOT NULL,
  achievement text DEFAULT '',
  created_at timestamptz DEFAULT now()
);
```

#### `user_profiles` / `user_permissions` — team accounts & per-pipeline access
Created by [`supabase-auth-migration.sql`](supabase-auth-migration.sql), not by hand — see that file for the full schema, the auto-profile trigger, and the RLS policies. Summary:
```sql
CREATE TABLE user_profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text NOT NULL,
  name text,
  is_admin boolean NOT NULL DEFAULT false,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz DEFAULT now()
);
CREATE TABLE user_permissions (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  section text NOT NULL,        -- matches a sidebar item, e.g. 'pipeline', 'coldcalling', 'clientpayments'
  can_view boolean NOT NULL DEFAULT true,
  can_edit boolean NOT NULL DEFAULT false,
  UNIQUE(user_id, section)
);
```

### Authentication & Row Level Security
⚠️ The instructions that used to be here (`DISABLE ROW LEVEL SECURITY` on every table) are **no longer used** — that left the whole database wide open behind nothing but a client-side string comparison, readable by anyone in the page source. The app now uses real Supabase Auth (individual per-teammate logins) with per-pipeline permissions enforced by real RLS policies.

Run **[`supabase-auth-migration.sql`](supabase-auth-migration.sql)** in the Supabase SQL editor to set this up — it's split into clearly-labeled stages (schema → deploy code → enable RLS → narrow individual access) with an explanation of what to do and verify at each one. Do not paste the whole file at once; follow the staged rollout notes at the top of the file.

Two new tables back this: `user_profiles` (one row per teammate, linked to `auth.users`, with `is_admin`/`is_active` flags) and `user_permissions` (per-user, per-pipeline `can_view`/`can_edit` grants). Both are created by the migration file — see it for the exact schema.

New team members can be added two ways — pick whichever's set up:
- **In-app** — Settings → Team Access → **+ Add User** (admin-only), which creates the login for you via a Supabase Edge Function. Requires the one-time Edge Function deploy below.
- **Manually** — Supabase Dashboard → Authentication → Users → Add user.

Either way, self-signup stays intentionally disabled (nobody can register their own account by hitting the Auth API directly). Once logged in, an admin manages who can see which pipeline from **Settings → Team Access** inside the app.

#### Deploying the "Add User" Edge Function (one-time)
The in-app "+ Add User" button calls a small server-side function (`supabase/functions/create-user`) that holds Supabase's `service_role` key — the key that can create logins — entirely server-side. That key is never present in `index.html` or the browser; it's injected automatically by Supabase into the function's runtime. Deploy it with the [Supabase CLI](https://supabase.com/docs/guides/cli):
```bash
npm install -g supabase   # if you don't have it already
supabase login
supabase link --project-ref iededwksmveomkrhofzu
supabase functions deploy create-user
```
No manual secrets to set — `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `SUPABASE_SERVICE_ROLE_KEY` are provided to every Edge Function automatically. The function itself re-checks that the caller is an active admin (via `user_profiles`) before creating anything, so even though the endpoint is reachable with just the anon key, only an admin's request actually succeeds. If you skip this deploy, "+ Add User" will just show an error — the Dashboard method above always works as a fallback.

### Remove Duplicate Leads (LinkedIn Pipeline)
```sql
DELETE FROM leads
WHERE id NOT IN (
  SELECT MIN(id)
  FROM leads
  GROUP BY
    LOWER(TRIM(first_name)),
    LOWER(TRIM(last_name)),
    LOWER(TRIM(COALESCE(email, '')))
);
```

---

## 🚀 Getting Started

1. Clone or download the repository
2. Run `supabase-auth-migration.sql`'s Stage 1 block in Supabase, then add your own account via Dashboard → Authentication → Users and flag it admin (see the migration file's comments)
3. Open `index.html` in your browser — or deploy to Vercel
4. Sign in with your team account (see [Authentication & Row Level Security](#authentication--row-level-security))
5. Select a pipeline from the left sidebar

---

## 🧭 Navigation

The sidebar is grouped into sections. Items marked **soon** are placeholders not yet built:

| Section | Items |
|---|---|
| Overview | Dashboard *(soon)*, All Contacts, Hot Pipeline, Active Clients |
| Pipeline | LinkedIn Pipeline, Freelance Pipeline, Cold Calling, Email Campaign, Paid Leads |
| Delivery | Projects *(soon)*, Tasks *(soon)* |
| Revenue | Client Payments, Balance Sheet, Proposals *(soon)*, Invoices *(soon)* |
| Data | Import *(soon)*, Settings |

---

## 🚪 Pipelines

### 💼 LinkedIn Pipeline

Full-featured CRM for LinkedIn affiliate outreach.

#### Tabs
| Tab | Description |
|---|---|
| 🗂️ Kanban | Drag & drop contacts across pipeline stages |
| 👥 Contacts | Sortable table with search & filter |
| 📅 Calendar | Monthly view with follow-up events |
| ✉️ Templates | Message templates with variable insertion |
| 📊 Analytics | Pipeline charts & revenue graphs |
| 📋 Activity | Team daily activity log with calendar & export |

#### How to use
1. **Add contacts** via `+ Add` or CSV import
2. **Drag contacts** across stages as outreach progresses
3. **Drop to Follow Up** → set date & notes → appears in Calendar
4. **Drop to Won** → enter deal details → contact is **automatically cloned into Hot Pipeline**
5. **Drop to Lost** → select reason tag
6. **Check bell 🔔** daily for overdue follow-ups

---

### 🔥 Hot Pipeline

Multi-channel sales tracker for Fiverr, Upwork, LinkedIn, Email, WhatsApp, and Calling leads.

#### Stages
`Fiverr` → `Upwork` → `LinkedIn` → `Email` → `WhatsApp` → `Calling` → `Freelancer` → `Paid Leads` → `Follow Up` → `Won` → `Loss`

#### Stat Boxes
| Box | What it shows |
|---|---|
| Fiverr / Upwork / LinkedIn / Email / WhatsApp / Calling / Freelancer / Paid Leads Sales | Won revenue per source channel |
| Total Sales | Sum of all sale values |
| Pending Revenue | Total Sales minus Won Revenue |
| Monthly Sales | Last month vs this month comparison |

#### How to use
1. Click **+ Add Contact** at the bottom of any column
2. Fill in name, account name, source & sale value
3. Source tag is permanent — never changes on drag
4. Use **Month Picker** to view historical snapshots
5. Click **📊 Insight** for multi-month analytics

---

### 🧩 Freelance Pipeline

Freelance platform lead tracker with project and platform analytics.

#### Stages
`Fiverr` → `Upwork` → `Freelancer` → `Connected` → `Follow Up` → `Lost` → `WON`

#### Tabs
| Tab | Description |
|---|---|
| 🗂️ Kanban | Drag & drop with source filtering |
| 👥 Contacts | Table view with search |
| 📅 Calendar | Follow-up reminders |
| ✉️ Templates | Message templates |
| 📊 Analytics | Stage breakdown + leads by platform |
| 📋 Activity | Team daily activity log with calendar & export |

---

### 📞 Cold Calling

Phone outreach pipeline with call status tracking and appointment booking.

#### Stages
`Awin Leads` → `SN Leads` → `Apollo Leads` → `Other Leads` → `Call Status` → `Follow Up` → `DND` → `Lost` → `Appointment Booked` → `Won`

#### Tabs
| Tab | Description |
|---|---|
| 🗂️ Kanban | Drag & drop with source filtering |
| 👥 Contacts | Table view with search |
| 📅 Calendar | Follow-up and appointment reminders |
| 📊 Analytics | Stage breakdown + call status chart |
| 📋 Activity | Team daily activity log with calendar & export |

#### How to use
1. Import leads via Apollo/SN CSV or add manually
2. Log **Call Status** when you connect — a modal captures the outcome
3. **Appointment Booked** → set date/time → appears on Calendar
4. Overdue appointments trigger a Review popup: Won / Reschedule / No Show

---

### ✉️ Email Campaign

Email outreach pipeline for tracking campaigns from lead to close.

#### Stages
`Awin Leads` → `SN Leads` → `Apollo Leads` → `Other Leads` → `Connected` → `Follow Up` → `DND` → `Lost` → `Appointment Booked` → `Won`

#### Tabs
| Tab | Description |
|---|---|
| 🗂️ Kanban | Drag & drop with source filtering |
| 👥 Contacts | Table view with search |
| 📅 Calendar | Follow-up and appointment reminders |
| ✉️ Templates | Email templates |
| 📊 Analytics | Stage breakdown analytics |
| 📋 Activity | Team daily activity log with calendar & export |

---

### 💵 Paid Leads

Lead tracker for paid ad campaigns (Meta Ads, Google Ads, LinkedIn Ads).

#### Stages
`Meta Ads` → `Google Ads` → `Linked Ads` → `Connected` → `Follow Up` → `Appointment Booked` → `Trash` → `Lost` → `WON`

#### Tabs
| Tab | Description |
|---|---|
| 🗂️ Kanban | Drag & drop with source filtering |
| 👥 Contacts | Table view with search |
| 📅 Calendar | Follow-up and appointment reminders |
| 📊 Analytics | Stage breakdown analytics |

---

### 👥 Active Clients

Monthly client lifecycle manager.

#### Columns
| Column | Description |
|---|---|
| Active Clients | Clients active this month |
| Winning Clients | Hot Pipeline Won leads for the month (auto-synced) |
| Lost Clients | Clients marked lost this month with reason |
| Comparison Graph | Current vs previous month revenue bar chart |

#### Stats Bar
| Stat | Description |
|---|---|
| Active / Winning / Lost counts | Client counts per column |
| Active Revenue | Sum of revenue from Active clients |
| Won Revenue | Sum of sale value from Winning clients |
| Lost Revenue | Sum of revenue from Lost clients |
| Total Revenue | Active Revenue + Won Revenue |

#### Key behaviours
- **Auto-roll** — on first load of a new month, Active + Winning clients carry forward automatically
- **Mark Lost** — modal asks for reason; stored with the record permanently
- **Restore Active** — move a lost client back to Active in one click
- **Active Projects / Lost Projects** — YTD lists, both exportable as CSV
- Past months are read-only historical snapshots

---

### 💳 Client Payments

Contract and installment tracker for revenue already closed in Active Clients and Hot Pipeline.

#### Tabs
| Tab | Description |
|---|---|
| 📄 Client Contracts | One row per contract (from Active Clients + Hot Pipeline Won); edit payment source, condition & remarks |
| 💳 Payment Status | Log individual installments against a contract with a status (Pending / Paid / Balance Lost) and PKR received amount |
| 🗓️ Payment Calendar | Calendar view of scheduled payments |

#### Stat Boxes
| Box | What it shows |
|---|---|
| Total Revenue | Sum of `amount_closed` across all contracts for the selected month |
| Confirm Payment | Sum of all logged installment amounts (click to view entries) |
| Client Paid | Sum of installments with status `Paid` |
| Pending Balance | Sum of installments with status `Pending` (click to view breakdown) |
| Balance Lost | Sum of installments with status `Balance Lost` |
| Amount Received (PKR) | Sum of `received_pkr` across all installments |

#### Key behaviours
- **Month Picker** supports selecting future months in addition to past/current
- **Auto-roll** — unpaid `Pending` installments roll forward into the current month automatically
- Contracts are read from `active_clients` (status = active for the month) and `hot_pipeline` (`stage = Won`, won in that month) — payment metadata is stored separately in `client_payments` keyed by source

---

### 🧾 Balance Sheet

An in-app spreadsheet for tracking expenses — Excel/Google Sheets-style, organized like a workbook per month: each month can hold one or more sheets (tabs). (Sidebar label: **Balance Sheet**; internally still referred to as "Expenses" in the codebase and Supabase table name.)

#### Layout
- Column headers `A`–`Z` and row numbers, sticky while scrolling — every cell is directly editable
- **Calendar dropdown** at the top switches between months; picking a month with no sheet yet creates its first sheet immediately (no prompts)
- **Formula bar** shows the selected cell's address and raw content (value or formula)
- **Revenue (PKR) box** — a fixed box next to the calendar dropdown, pulled live from Client Payments → Payment Status → Amount Received (PKR) for the currently active month (sums `received_pkr` across that month's `payment_entries`, same figure Client Payments shows). Switching months updates it automatically.
- **Total Expenses box** — built-in, appears automatically on every sheet right after Revenue (no need to create it via +Add Box). Starts at ₨0; click it to set/edit that sheet's formula (e.g. `=SUM(B2:B31)`). Each sheet keeps its own formula, so different months (or different sheets within a month) can total different columns.
- **Available Balance** — a fixed box right after Total Expenses, computed automatically as `Revenue (PKR) − Total Expenses` (green if positive, red if negative). No formula to set — it just reflects the two boxes next to it, live, for whichever month you're viewing.
- **Summary boxes** — click **+ Add Box** to create a custom box with a name and a formula (e.g. `=SUM(B2:B30)`), displayed in **PKR (₨)**; click an existing box to edit or delete it
- **Formatting toolbar** — select a single cell or click-and-drag a range, then apply **Bold**, text color, background color, **Merge**/**Unmerge**, or set a **Dropdown** (comma-separated options, turning those cells into a `<select>`)
- **Sheet tabs** at the bottom are scoped to the currently active month (like tabs within one Excel workbook) — **+ Add Sheet** adds another sheet *within that same month* (auto-named "Sheet 2", "Sheet 3", …); double-click a tab to rename it (e.g. "Rent", "Travel"), click **×** to delete it. To start a *different* month, use the calendar dropdown, not "+ Add Sheet"
- **+ 15 Rows** button expands the grid (up to 200 rows) if a sheet needs more line items
- **Import / Export** — available on every sheet (new or existing), next to the formula bar. Columns A–E on every sheet are treated as a fixed ledger: **Date, Description, Amount, Remarks, Project**.
  - **Import** accepts a CSV with a header row containing those column names in any order (matched case-insensitively) — writes the bold header row into A1:E1 if not already present, then appends the rows after whatever data already exists on that sheet.
  - **Export** downloads a CSV of just those 5 columns (skipping blank rows), with the standard header row, regardless of what's actually typed in A1:E1 on the sheet.
- Keyboard: **Enter** or **Tab** commits the cell and moves the cursor to the next cell on the right (Shift+Tab moves left), wrapping to the next/previous row at the sheet edges. **Arrow keys** move between cells in any direction (↑/↓ always; ←/→ move the cell once the text cursor is at the start/end of the cell's content, so editing text within a cell still works normally). **Delete/Backspace** clears every cell in the current selection in one press when a multi-cell range is selected (click-and-drag first); on a single cell it just edits the text as normal, with no data loss

#### Formulas
Cells starting with `=` are evaluated by a small formula engine (tokenizer → parser → evaluator) supporting:
- Cell references and ranges: `=A1`, `=B2*1.1`, `=SUM(B2:B30)`
- Operators: `+ - * / ^` (power), `&` (text concatenation), comparisons `= <> < > <= >=`
- Text literals in double quotes: `="Total: "&B2`
- Math: `SUM`, `AVERAGE`/`AVG`, `MIN`, `MAX`, `COUNT`, `COUNTA`, `ABS`, `ROUND`, `ROUNDUP`, `ROUNDDOWN`, `SQRT`, `POWER`, `MOD`, `CEILING`, `FLOOR`, `PRODUCT`
- Logic: `IF`, `AND`, `OR`, `NOT`, `IFERROR`
- Text: `CONCAT`/`CONCATENATE`, `LEFT`, `RIGHT`, `MID`, `LEN`, `UPPER`, `LOWER`, `TRIM`
- Date: `TODAY`, `NOW`, `YEAR`, `MONTH`, `DAY`
- Circular references resolve to `0` rather than hanging

This covers the practical set most expense sheets need — it isn't a full reimplementation of every Excel function (there are hundreds), but it's a real tokenizer/parser, not string substitution, so nesting and quoted text work correctly (e.g. `=IF(B2>100,"Over","OK")`).

#### Formatting & structure
Each sheet stores: `cells` (value/formula per address), `styles` (bold/text color/background per address), `merges` (list of `{start,end}` cell ranges), and `dropdowns` (options list per address) — all as JSON, so there's no fixed column schema; use the columns however fits (Date, Category, Vendor, Amount, etc.).

---

### 🗂️ All Contacts

Unified search view across LinkedIn Pipeline, Hot Pipeline, Freelance Pipeline, Cold Calling, Email Campaign, and Paid Leads.

- Filter by pipeline, industry, and stage
- Export filtered results as CSV
- Read-only — edits must be made inside each pipeline

---

## 📋 Activity Log

Every pipeline (LinkedIn, Freelance, Cold Calling, Email Campaign) has an **Activity** tab for logging daily team activity.

### Features
| Feature | Description |
|---|---|
| Log view | Table of all entries: Date, Name, Activity, Achievement |
| Date range filter | Filter entries by From → To date |
| ⬇ Export | Download filtered entries as CSV |
| + Add Entry | Log a new activity with date, name, activity description, and achievement |
| Calendar view | Monthly calendar grid; days with entries are highlighted |
| Day detail | Click any calendar day to see that day's entries or add a new one |

### Supabase table required
```sql
CREATE TABLE activity_log (
  id bigserial PRIMARY KEY,
  pipeline text NOT NULL,
  date date NOT NULL,
  name text NOT NULL,
  activity text NOT NULL,
  achievement text DEFAULT '',
  created_at timestamptz DEFAULT now()
);
```

### Columns
| Column | Description |
|---|---|
| Date | The date of the activity (YYYY-MM-DD) |
| Name | Team member who performed the activity |
| Activity | What was done (calls made, emails sent, etc.) |
| Achievement | Notable win or result (optional) |

---

## 📥 CSV Import & Export

### Import (LinkedIn Pipeline)
- **📥 Import** — imports contacts to `Cold` stage
- **🔍 SN Import** — imports contacts to `Sales Navigator` stage

#### CSV Format
```
firstname,lastname,linkedinurl,website,industry,affiliatenetwork,email
John,Doe,https://linkedin.com/in/johndoe,johndoe.com,SaaS,Impact,john@doe.com
```

### Duplicate Detection
On import the app checks same email address OR same first + last name. Duplicates are skipped and a summary is shown after import.

### Export
- **LinkedIn Pipeline** → Contacts tab → **⬇ Export**
- **All Contacts** → **⬇ Export** (filtered results)
- **Active Clients** → Active Projects / Lost Projects modal → **⬇ Export CSV**
- **Activity Log** → Activity tab → set date range → **⬇ Export**

---

## 🗂️ Stages Reference

### LinkedIn Pipeline
| Stage | Description |
|---|---|
| Cold | New uncontacted leads |
| Sales Navigator | Sourced via Sales Navigator |
| Connection Sent | LinkedIn connection request sent |
| Connected | Connection accepted |
| Follow Up | Scheduled follow-up pending |
| Won | Deal closed — auto-cloned to Hot Pipeline |
| Lost | Lead lost or not interested |

### Hot Pipeline
| Stage | Description |
|---|---|
| Fiverr / Upwork / LinkedIn / Email / WhatsApp / Calling / Freelancer / Paid Leads | Platform-sourced leads |
| Follow Up | Scheduled follow-ups |
| Won | Deals won — appear in Active Clients |
| Loss | Deals lost |

### Freelance Pipeline
| Stage | Description |
|---|---|
| Fiverr / Upwork / Freelancer | Platform-sourced leads |
| Connected | Initial contact made |
| Follow Up | Awaiting response |
| Lost | Lead not converted |
| WON | Deal closed |

### Cold Calling
| Stage | Description |
|---|---|
| Awin Leads / SN Leads / Apollo Leads / Other Leads | Lead source buckets |
| Call Status | Call attempted — outcome logged |
| Follow Up | Scheduled callback |
| DND | Do Not Disturb — opted out |
| Lost | Not converted |
| Appointment Booked | Meeting scheduled |
| Won | Deal closed |

### Email Campaign
| Stage | Description |
|---|---|
| Awin Leads / SN Leads / Apollo Leads / Other Leads | Lead source buckets |
| Connected | Email opened / replied |
| Follow Up | Follow-up email scheduled |
| DND | Do Not Disturb — opted out |
| Lost | Not converted |
| Appointment Booked | Meeting scheduled |
| Won | Deal closed |

### Paid Leads
| Stage | Description |
|---|---|
| Meta Ads / Google Ads / Linked Ads | Ad platform lead sources |
| Connected | Initial contact made |
| Follow Up | Scheduled follow-up |
| Appointment Booked | Meeting scheduled |
| Trash | Discarded/invalid lead |
| Lost | Not converted |
| WON | Deal closed |

---

## 🏷️ Tags

### Default Tags
| Tag | Usage |
|---|---|
| hot-lead | High priority leads |
| vip | VIP contacts |
| tech | Tech industry |
| cold | Cold leads |
| follow-up | Needs follow-up |
| saas | SaaS companies |
| agency | Agency contacts |
| lead | General leads |
| wholesale | Wholesale contacts |
| profiles | Profile-based leads |
| not-interested | Not interested leads |
| sales-navigator | Sales Navigator sourced |

Custom tags can be created by typing a name and pressing **Enter** in the tag input.

---

## 🔔 Notifications & Reminders

The bell icon 🔔 in the header shows overdue + today's follow-up count.

| Category | Description |
|---|---|
| 🔴 OVERDUE | Follow-up date has passed |
| 🟡 TODAY | Follow-up due today |
| 🔵 UPCOMING | Follow-ups in the next 7 days |

**Review Popup** (click any reminder):
- ✅ **Replied / Called** → advances contact to Connected/Call Status
- 🔁 **Follow Up Again** → reschedule
- ❌ **Lost / DND** → closes the lead

---

## 🌐 Deployment

### Vercel (Current)
1. Push `index.html` to GitHub repo
2. Vercel auto-deploys on every commit
3. Live at: [https://linked-crm.vercel.app](https://linked-crm.vercel.app)

### Update Process
1. Make changes in Claude Code
2. Commit and push `index.html` to GitHub
3. Vercel deploys automatically in ~30 seconds

---

## 🔐 Security

| Feature | Details |
|---|---|
| Login | Individual email + password per teammate, via Supabase Auth — no shared password, no self-signup |
| Session | Persisted in the browser (`localStorage`) with automatic token refresh; **Logout** in the top header clears it |
| Access control | Per-pipeline `can_view`/`can_edit` grants, managed by an admin in **Settings → Team Access**, enforced by Postgres Row Level Security — not just hidden in the UI |
| Database | Supabase with RLS **enabled** on every table (see [`supabase-auth-migration.sql`](supabase-auth-migration.sql)) — the anon key alone no longer grants any data access |
| Adding teammates | Supabase Dashboard → Authentication → Users → Add user, then grant their pipeline access from Team Access |
| Recommendation | Keep GitHub repo **Private** to protect credentials |

### Make GitHub Repo Private
1. Go to your GitHub repo → **Settings**
2. Scroll to **Danger Zone**
3. Click **Change visibility** → **Make private**
4. Vercel continues to work with private repos ✅

---

## 📞 Support

This CRM was custom built and is maintained privately. For changes or new features, update via Claude Code and redeploy to GitHub/Vercel.

---

*Built with ❤️ for sales and outreach professionals*

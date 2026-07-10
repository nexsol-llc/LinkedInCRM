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
  - [Expenses](#expenses)
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

#### `expense_sheets` — Expense spreadsheets (one row per month)
```sql
CREATE TABLE expense_sheets (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  month text NOT NULL UNIQUE,       -- format: 'YYYY-MM'
  name text,                        -- sheet display name, e.g. 'July 2026'
  cells jsonb DEFAULT '{}'::jsonb,  -- { "A1": "raw value or =formula", "B2": "250", ... }
  boxes jsonb DEFAULT '[]'::jsonb,  -- [{ "id": "...", "label": "Total Spend", "formula": "=SUM(B1:B30)" }]
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

### Disable RLS
Run this for all tables to allow API access:
```sql
ALTER TABLE leads DISABLE ROW LEVEL SECURITY;
ALTER TABLE templates DISABLE ROW LEVEL SECURITY;
ALTER TABLE hot_pipeline DISABLE ROW LEVEL SECURITY;
ALTER TABLE freelance_pipeline DISABLE ROW LEVEL SECURITY;
ALTER TABLE cold_calling DISABLE ROW LEVEL SECURITY;
ALTER TABLE email_campaign DISABLE ROW LEVEL SECURITY;
ALTER TABLE paid_leads DISABLE ROW LEVEL SECURITY;
ALTER TABLE active_clients DISABLE ROW LEVEL SECURITY;
ALTER TABLE active_clients_monthly_status DISABLE ROW LEVEL SECURITY;
ALTER TABLE client_payments DISABLE ROW LEVEL SECURITY;
ALTER TABLE payment_entries DISABLE ROW LEVEL SECURITY;
ALTER TABLE expense_sheets DISABLE ROW LEVEL SECURITY;
ALTER TABLE activity_log DISABLE ROW LEVEL SECURITY;
```

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
2. Open `index.html` in your browser — or deploy to Vercel
3. Enter password: `LinkedIn@7865`
4. Select a pipeline from the left sidebar

---

## 🧭 Navigation

The sidebar is grouped into sections. Items marked **soon** are placeholders not yet built:

| Section | Items |
|---|---|
| Overview | Dashboard *(soon)*, All Contacts, Hot Pipeline, Active Clients |
| Pipeline | LinkedIn Pipeline, Freelance Pipeline, Cold Calling, Email Campaign, Paid Leads |
| Delivery | Projects *(soon)*, Tasks *(soon)* |
| Revenue | Client Payments, Expenses, Proposals *(soon)*, Invoices *(soon)* |
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

### 🧾 Expenses

An in-app spreadsheet for tracking monthly expenses — Excel/Google Sheets-style, one sheet per month.

#### Layout
- Column headers (`A`, `B`, `C`, …) and row numbers, sticky while scrolling — every cell is directly editable
- **Formula bar** shows the selected cell's address and raw content (value or formula)
- **Summary boxes** at the top — click **+ Add Box** to create a custom box with a name and a formula (e.g. `=SUM(B2:B30)`); click an existing box to edit or delete it
- **Sheet tabs** at the bottom — click **+ Add Sheet** to create the next month's sheet; double-click a tab to rename it, click the **×** to delete it
- **+ 15 Rows** button expands the grid (up to 200 rows) if a sheet needs more line items

#### Formulas
Cells starting with `=` are evaluated as formulas:
- Cell references: `=A1`, `=B2*1.1`
- Ranges inside functions: `=SUM(B2:B30)`
- Functions: `SUM`, `AVERAGE` (or `AVG`), `MIN`, `MAX`, `COUNT`
- Standard arithmetic and parentheses: `=(A1+A2)/2`
- Circular references resolve to `0` rather than hanging

Each sheet stores its grid as a single JSON object (`cells`) keyed by cell address (e.g. `"B2": "250"` or `"B3": "=B1+B2"`), so there's no fixed schema — use the columns however fits (Date, Category, Vendor, Amount, etc.).

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
| Password | `LinkedIn@7865` — required on every session |
| Session | Stays unlocked until browser tab is closed |
| Database | Supabase with anon key (RLS disabled for simplicity) |
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

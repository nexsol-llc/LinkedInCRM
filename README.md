# 🚀 AffiLinks.io — Full CRM

> A powerful, production-ready affiliate outreach CRM with LinkedIn pipeline management, Hot Pipeline tracking, and Active Client lifecycle management. Built with React, powered by Supabase, and deployed on Vercel.

**Live URL:** [https://linked-crm.vercel.app](https://linked-crm.vercel.app)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Database Setup](#database-setup)
- [Getting Started](#getting-started)
- [Gates](#gates)
  - [LinkedIn CRM](#linkedin-crm)
  - [Hot Pipeline](#hot-pipeline)
  - [Active Clients](#active-clients)
- [CSV Import & Export](#csv-import--export)
- [Stages](#stages)
- [Tags](#tags)
- [Notifications & Reminders](#notifications--reminders)
- [Deployment](#deployment)
- [Security](#security)

---

## 🌟 Overview

AffiLinks.io is a custom-built CRM designed specifically for **affiliate marketers and outreach professionals**. It features three separate workspaces (Gates) accessible from a single password-protected dashboard:

- **💼 LinkedIn CRM** — Full-featured pipeline for managing LinkedIn outreach contacts
- **🔥 Hot Pipeline** — Multi-channel sales tracker for Fiverr, Upwork, LinkedIn, Email, WhatsApp, and Calling leads
- **👥 Active Clients** — Monthly client lifecycle manager with revenue tracking, historical records, and comparison analytics

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
- 📊 Analytics & revenue charts

### LinkedIn CRM
- 🗂️ Kanban board with drag & drop
- 👥 Contacts table with search, filter, sort
- 📅 Calendar with follow-up scheduling
- ✉️ Message templates with variables
- 📈 Monthly revenue column chart
- 💰 Deal closing with amount, date & contract
- 🔁 Follow-up history & attempt tracking
- 🔔 Overdue reminders with Review popup
- 🔍 Dedicated Sales Navigator CSV import
- 🔗 **Auto-clone to Hot Pipeline** — dragging a contact to Won automatically creates a copy in Hot Pipeline under the LinkedIn column

### Hot Pipeline
- 🔥 9-stage Kanban board (Fiverr, Upwork, LinkedIn, Email, WhatsApp, Calling, Follow Up, Won, Loss)
- 💰 Per-channel sales stat boxes (Fiverr, Upwork, LinkedIn, Email, WhatsApp, Calling)
- 📊 Pending Revenue and Revenue (Won) prominently displayed
- 📅 Month picker — view any historical month's pipeline snapshot
- 📈 Monthly Sales comparison widget (last month vs this month, clickable)
- 📊 Insight chart with multi-month analytics
- 🔍 Search box — filter all kanban cards live by name, email, account, industry
- 📌 Permanent source tag (sticks when dragged across stages)
- 🏢 Account Name, Industry, Sale Value per contact

### Active Clients
- 👥 Three-column kanban: **Active Clients**, **Winning Clients**, **Lost Client**
- 📅 Month picker with full historical navigation
- 🔍 Search box — filter across all three columns live
- 🔄 **Auto-roll on new month** — on first load of a new month, Active + Winning clients from previous month are automatically carried forward as Active; Lost clients are excluded
- 🏆 **Winning Clients** auto-synced from Hot Pipeline Won leads for the selected month
- 🚩 **Mark Lost with reason** — modal appears asking for loss reason, stored permanently with the record
- 🔁 **Restore to Active** — move a lost client back to active in one click
- 💰 Revenue tracking per client (Active Revenue, Won Revenue, Lost Revenue, Total Revenue)
- 📊 **Comparison Graph** — bar chart comparing current vs previous month across all 4 revenue metrics, with a colour-coded improvement summary
- 📋 **Active Projects** — YTD (Jan–present) list of all active + winning clients, exportable to CSV
- 📋 **Lost Projects** — YTD list of all lost clients with reason and month, exportable to CSV
- 📅 Past months are read-only historical snapshots — no accidental edits

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

#### `leads` — LinkedIn CRM contacts
```sql
create table leads (
  id bigint primary key generated always as identity,
  first_name text,
  last_name text,
  linkedin_url text,
  website text,
  industry text,
  affiliate_network text,
  email text,
  stage text default 'Cold',
  tags text[] default '{}',
  follow_up jsonb,
  deal jsonb,
  follow_up_history jsonb[] default '{}',
  created_at timestamptz default now()
);
```

#### `templates` — Message templates
```sql
create table templates (
  id bigint primary key generated always as identity,
  name text,
  body text,
  created_at timestamptz default now()
);
```

#### `hot_pipeline` — Hot Pipeline contacts
```sql
create table hot_pipeline (
  id bigint primary key generated always as identity,
  first_name text,
  last_name text,
  linkedin_url text,
  website text,
  industry text,
  email text,
  account_name text,
  source text,
  stage text default 'Fiverr',
  sale_value numeric default 0,
  tags text[] default '{}',
  follow_up jsonb,
  deal jsonb,
  follow_up_history jsonb[] default '{}',
  won_at timestamptz,
  created_at timestamptz default now()
);
```

#### `active_clients` — Active Client records
```sql
create table active_clients (
  id bigint primary key generated always as identity,
  first_name text,
  last_name text,
  company text,
  email text,
  phone text,
  contract_terms text,
  revenue numeric default 0,
  source text default 'manual',
  hot_pipeline_id bigint references hot_pipeline(id),
  created_at timestamptz default now()
);
```

#### `active_clients_monthly_status` — Per-month status tracking
```sql
create table active_clients_monthly_status (
  id bigint primary key generated always as identity,
  client_id bigint references active_clients(id),
  month text,        -- format: 'YYYY-MM'
  status text,       -- 'active' | 'lost'
  reason text,       -- loss reason (optional)
  created_at timestamptz default now(),
  unique(client_id, month)
);
```

### Disable RLS
Run this for all tables to allow API access:
```sql
alter table leads disable row level security;
alter table templates disable row level security;
alter table hot_pipeline disable row level security;
alter table active_clients disable row level security;
alter table active_clients_monthly_status disable row level security;
```

### Remove Duplicate Leads
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
4. Select a gate from the left sidebar: **LinkedIn CRM**, **Hot Pipeline**, or **Active Clients**

---

## 🚪 Gates

### 💼 LinkedIn CRM

A full-featured CRM for managing LinkedIn affiliate outreach.

#### Tabs
| Tab | Description |
|---|---|
| 🗂️ Kanban | Drag & drop contacts across pipeline stages |
| 👥 Contacts | Sortable table with search & filter |
| 📅 Calendar | Monthly view with follow-up events |
| ✉️ Templates | Message templates with variable insertion |
| 📊 Analytics | Pipeline charts & revenue graphs |

#### How to use
1. **Add contacts** via `+ Add` button or CSV import
2. **Drag contacts** across stages as your outreach progresses
3. **Drop to Follow Up** → set date & notes → appears on Calendar
4. **Drop to Won** → enter closing date, deal amount & contract → contact is **automatically cloned into Hot Pipeline** under the LinkedIn column
5. **Drop to Lost** → select reason tag (optional)
6. **Check bell 🔔** daily for overdue follow-ups

---

### 🔥 Hot Pipeline

A multi-channel sales tracker for managing leads from different platforms.

#### Stages (Columns)
`Fiverr` → `Upwork` → `LinkedIn` → `Email` → `WhatsApp` → `Calling` → `Follow Up` → `Won` → `Loss`

#### Stat Boxes
| Box | What it shows |
|---|---|
| Fiverr Sales | Total value of all Fiverr-sourced Won contacts |
| Upwork Sales | Total value of all Upwork-sourced Won contacts |
| LinkedIn Sales | Total value of all LinkedIn-sourced Won contacts |
| Email Sales | Total value of all Email-sourced Won contacts |
| WhatsApp | Total value of all WhatsApp-sourced Won contacts |
| Calling Sales | Total value of all Calling-sourced Won contacts |
| Total Sales | Sum of all sale values across all contacts |
| Pending Revenue | Total Sales minus Revenue Won |
| Monthly Sales | Last month vs this month comparison (click last month to navigate) |
| Revenue (Won) | Total value of contacts in the Won stage — prominently displayed |

#### Search
Use the 🔍 search box (before the month picker) to filter all kanban cards live by name, email, account name, or industry.

#### How to use
1. Click **+ Add Contact** at the bottom of any column
2. Fill in name, account name, email, industry, source & sale value
3. **Source tag is permanent** — it never changes even when dragged
4. Drag contacts across stages as deals progress
5. Stats update live at the top
6. Use the **Month Picker** to view any past month's snapshot
7. Click **📊 Insight** for multi-month analytics charts

---

### 👥 Active Clients

A monthly client lifecycle manager that tracks your active, winning, and lost clients with full history.

#### Columns
| Column | Description |
|---|---|
| Active Clients | Clients currently active this month |
| Winning Clients | Hot Pipeline Won leads for the selected month (auto-synced) |
| Lost Client | Clients marked as lost this month, with reason |
| Comparison Graph | Current vs previous month revenue chart |

#### Stats Bar
| Stat | Description |
|---|---|
| Active Clients | Count of active clients this month |
| Winning This Month | Count of HP Won leads this month |
| Lost Clients | Count of lost clients this month |
| Active Revenue | Sum of revenue from Active clients |
| Won Revenue | Sum of sale value from Winning clients |
| Lost Revenue | Sum of revenue from Lost clients (red) |
| Total Revenue | Active Revenue + Won Revenue (prominent purple box) |

#### Month Navigation
- Use the **Month Picker** to jump to any historical month — past months are **read-only** snapshots
- **Auto-roll**: on the first load of a new calendar month, the app automatically carries Active + Winning clients from the previous month into the new month as Active. Lost clients are never carried forward.

#### Active Projects & Lost Projects
- Click **Active Projects** (green button, next to month picker) to see all clients active or winning at any point this year (Jan–present)
- Click **Lost Projects** (red button) to see all clients lost this year with their reason and month
- Both modals support **⬇ Export CSV** to download the full list

#### Comparison Graph
- Positioned as a 4th panel next to the Lost Client column
- Shows a grouped bar chart comparing **current selected month vs previous month** across Active Revenue, Won Revenue, Lost Revenue, and Total Revenue
- Colour-coded improvement summary below the chart:
  - For Lost Revenue: losing less is shown as an improvement (green)
  - All other metrics: higher is better (green)

#### How to use
1. **Add a client** manually with `+ Add Client` — name, company, email, phone, revenue, and contract terms (required)
2. Winning Clients auto-appear from Hot Pipeline — no manual entry needed
3. **Mark Lost** → a modal appears asking for the reason → client moves to Lost column with the reason displayed on the card
4. **Restore Active** → move a lost client back to Active
5. Navigate to past months to review historical data
6. Use the 🔍 search box to find any client across all columns

---

## 📥 CSV Import & Export

### Import (LinkedIn CRM)
- **📥 Import** — imports contacts to `Cold` stage
- **🔍 SN Import** — imports contacts directly to `Sales Navigator` stage with `sales-navigator` tag

#### CSV Format
```
firstname,lastname,linkedinurl,website,industry,affiliatenetwork,email
John,Doe,https://linkedin.com/in/johndoe,johndoe.com,SaaS,Impact,john@doe.com
```

### Duplicate Detection
On import, the app checks:
- Same **email address**, OR
- Same **first name + last name**

Duplicates are automatically skipped. A summary is shown after import:
```
✅ 150 contacts imported
⚠️ 23 duplicates skipped
```

### Export
- **LinkedIn CRM** — Click **⬇️ Export** to download all contacts as `.csv`
- **Active Clients** — Click **Active Projects** or **Lost Projects** → click **⬇ Export CSV** inside the modal

---

## 🗂️ Stages

### LinkedIn CRM Stages
| Stage | Description |
|---|---|
| Cold | New uncontacted leads |
| Sales Navigator | Leads sourced via Sales Navigator |
| Connection Sent | LinkedIn connection request sent |
| Connected | Connection accepted |
| Follow Up | Scheduled follow-up |
| Won | Deal closed — auto-cloned to Hot Pipeline |
| Lost | Lead lost or not interested |

### Hot Pipeline Stages
| Stage | Description |
|---|---|
| Fiverr | Fiverr platform leads |
| Upwork | Upwork platform leads |
| LinkedIn | LinkedIn platform leads (includes clones from LinkedIn CRM Won) |
| Email | Email outreach leads |
| WhatsApp | WhatsApp leads |
| Calling | Phone call leads |
| Follow Up | Scheduled follow-ups |
| Won | Deals won — appear in Active Clients Winning column |
| Loss | Deals lost |

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

### Custom Tags
Type any tag name in the tag input and press **Enter** to create custom tags.

---

## 🔔 Notifications & Reminders

The bell icon 🔔 in the header shows a red badge with the count of overdue + today's follow-ups.

### Reminder Categories
| Category | Description |
|---|---|
| 🔴 OVERDUE | Follow-up date has passed |
| 🟡 TODAY | Follow-up due today |
| 🔵 UPCOMING | Follow-ups in the next 7 days |

### Review Popup
Click any overdue/today reminder to open the Review popup:
- ✅ **They Replied** → moves contact to Connected
- 🔁 **Follow Up Again** → reschedule with quick +3/+7/+14 day buttons
- ❌ **Not Interested** → moves contact to Lost

### Follow-Up History
Every follow-up attempt is logged with date and notes. The attempt number shows on the card (e.g. `#3`).

---

## 🌐 Deployment

### Vercel (Current)
1. Push `index.html` to GitHub repo (`LinkedCRM`)
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
| Password | `LinkedIn@7865` — shown once at login |
| Session | Stays unlocked until browser tab is closed |
| Database | Supabase with anon key (RLS disabled for simplicity) |
| Recommendation | Set GitHub repo to **Private** to hide credentials |

### Make GitHub Repo Private
1. Go to your GitHub repo → **Settings**
2. Scroll to **Danger Zone**
3. Click **Change visibility** → **Make private**
4. Vercel continues to work with private repos ✅

---

## 📞 Support

This CRM was custom built and is maintained privately. For changes or new features, update via Claude Code and redeploy to GitHub/Vercel.

---

*Built with ❤️ for affiliate outreach professionals*

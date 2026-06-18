# 🚀 AffiLinks.io — Full CRM

> A powerful, production-ready affiliate outreach CRM with LinkedIn pipeline management and Hot Pipeline tracking. Built with React, powered by Supabase, and deployed on Vercel.

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
- [CSV Import & Export](#csv-import--export)
- [Stages](#stages)
- [Tags](#tags)
- [Notifications & Reminders](#notifications--reminders)
- [Deployment](#deployment)
- [Security](#security)

---

## 🌟 Overview

AffiLinks.io is a custom-built CRM designed specifically for **affiliate marketers and outreach professionals**. It features two separate workspaces (Gates) accessible from a single password-protected dashboard:

- **💼 LinkedIn CRM** — Full-featured pipeline for managing LinkedIn outreach contacts
- **🔥 Hot Pipeline** — Multi-channel sales tracker for Fiverr, Upwork, LinkedIn, Email, WhatsApp, and Calling leads

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

### Hot Pipeline
- 🔥 9-stage Kanban board (Fiverr, Upwork, LinkedIn, Email, WhatsApp, Calling, Follow Up, Won, Loss)
- 💰 Per-channel sales stat boxes
- 📌 Permanent source tag (sticks when dragged across stages)
- ➕ Add contact directly to any column
- 🏢 Account Name field per contact
- 💵 Sale value entry per contact
- 📊 Live revenue aggregation by channel

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Frontend | React 18 (via CDN + Babel) |
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
  created_at timestamptz default now()
);
```

### Important: Disable RLS
Run this for all tables to allow API access:
```sql
alter table leads disable row level security;
alter table templates disable row level security;
alter table hot_pipeline disable row level security;
```

### Remove Duplicates
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
4. Select a gate: **LinkedIn CRM** or **Hot Pipeline**

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
4. **Drop to Won** → enter closing date, deal amount & contract
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
| Fiverr Sales | Total sale value of all Fiverr-sourced contacts |
| Upwork Sales | Total sale value of all Upwork-sourced contacts |
| LinkedIn Sales | Total sale value of all LinkedIn-sourced contacts |
| Email Sales | Total sale value of all Email-sourced contacts |
| Calling Sales | Total sale value of all Calling-sourced contacts |
| Total Sales | Sum of all sale values across all contacts |
| Revenue (Won) | Total value of contacts in the Won stage |

#### How to use
1. Click **+ Add Contact** at the bottom of any column
2. Fill in name, account name, email, industry, source & sale value
3. **Source tag is permanent** — it never changes even when dragged
4. Drag contacts across stages as deals progress
5. Stats update live at the top

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
Click **⬇️ Export** to download all contacts as a `.csv` file including all fields.

---

## 🗂️ Stages

### LinkedIn CRM Stages
| Stage | Color | Description |
|---|---|---|
| Cold | 🟣 Purple | New uncontacted leads |
| Sales Navigator | 🩵 Teal | Leads sourced via Sales Navigator |
| Connection Sent | 🟡 Yellow | LinkedIn connection request sent |
| Connected | 🔵 Blue | Connection accepted |
| Follow Up | 🟤 Purple | Scheduled follow-up |
| Won | 🟢 Green | Deal closed successfully |
| Lost | 🔴 Red | Lead lost or not interested |

### Hot Pipeline Stages
| Stage | Color | Description |
|---|---|---|
| Fiverr | 🟢 Green | Fiverr platform leads |
| Upwork | 🟢 Light Green | Upwork platform leads |
| LinkedIn | 🔵 Blue | LinkedIn platform leads |
| Email | 🟡 Yellow | Email outreach leads |
| WhatsApp | 🟢 WhatsApp Green | WhatsApp leads |
| Calling | 🟤 Purple | Phone call leads |
| Follow Up | 🟠 Orange | Scheduled follow-ups |
| Won | 🟢 Green | Deals won |
| Loss | 🔴 Red | Deals lost |

---

## 🏷️ Tags

### Default Tags
| Tag | Color | Usage |
|---|---|---|
| hot-lead | 🔴 Red | High priority leads |
| vip | 🟡 Yellow | VIP contacts |
| tech | 🔵 Blue | Tech industry |
| cold | 🟣 Purple | Cold leads |
| follow-up | 🟤 Purple | Needs follow-up |
| saas | 🩵 Teal | SaaS companies |
| agency | 🌸 Pink | Agency contacts |
| lead | 🟢 Green | General leads |
| wholesale | 🟠 Orange | Wholesale contacts |
| profiles | 🟣 Violet | Profile-based leads |
| not-interested | ⚫ Gray | Not interested leads |
| sales-navigator | 🩵 Teal | Sales Navigator sourced |

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
1. Make changes in Claude
2. Copy updated `index.html`
3. Replace file in GitHub repo
4. Vercel deploys automatically in ~30 seconds

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

This CRM was custom built and is maintained privately. For changes or new features, update via Claude AI and redeploy to GitHub/Vercel.

---

*Built with ❤️ for affiliate outreach professionals*
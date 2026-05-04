# Bloom Coffee

Customer menu, cart, and pickup orders powered by Rails 8 — plus Hotwire-backed admin tooling for drinks and add-ons.

---

## How to run (for reviewers)

All commands assume you are inside the **`app/`** directory (`cd app` after cloning). Ruby and Bundler resolve from `.ruby-version` / `Gemfile.lock`.

### Prerequisites

- **Ruby** `3.3.7`
- **PostgreSQL** reachable locally (`brew services start postgresql@…` etc.)
- Typical dev DB settings use your OS username and no password; override with **`PGHOST`**, **`PGUSER`**, **`PGPASSWORD`** if needed (see `config/database.yml`).

### Install dependencies and database

```bash
bundle install
bin/rails db:prepare
```

### Required environment variables (admin seed)

Admin users are **not** self‑service sign-up. For **local development**, **`ADMIN_EMAIL`** and **`ADMIN_PASSWORD`** can be any values you’ll use to sign in — seeds upsert exactly one admin from them.

```bash
cp .env.example .env
```

Then:

```bash
bin/rails db:seed
```

**Test environment:** `config/environments/test.rb` defaults to **`ADMIN_EMAIL=admin@test.test`** and **`ADMIN_PASSWORD=12345678`** whenever those env vars are unset, so **`RAILS_ENV=test bin/rails db:seed`** and CI work without `.env`. Export overrides if you need different values.

`db:seed` is idempotent for the admin (same email is updated); sample drinks/add-ons fill only empty tables.

### Start the app (development)

```bash
bin/dev
```

This runs **`bin/rails server`** and **`tailwindcss:watch`** (see `Procfile.dev`). Open **http://localhost:3000**.

One-off equivalent:

```bash
bin/rails tailwindcss:build   # CSS only, if you aren’t watching assets
bin/rails server
```

### Tests and lint (optional)

```bash
bundle exec rspec
bin/rubocop -f progress
```

---

## Deploy

Deployed on **[Render](https://render.com/)** (`render.yaml`: web service **`rootDir: app`**, managed PostgreSQL).

**Live URL:** [https://bloom-coffee-7rbj.onrender.com/](https://bloom-coffee-7rbj.onrender.com/)

Render’s **free tier** sleeps when idle — the **first request after wake** often takes roughly **30–60 seconds**.

The build pipeline runs `bin/render-build.sh`: `bundle install`, `assets:precompile`, **`db:migrate`**, **`db:seed`**.  
Set **`RAILS_MASTER_KEY`**, **`ADMIN_EMAIL`**, and **`ADMIN_PASSWORD`** in the Render dashboard (these are **not** in the repo). The seeded admin credentials on production must match whatever you configured there — use the reviewer-facing pair below if this deployment matches the shared demo setup.

---

## Admin login on Live App

**Sign-in URL:** **`/admin/login`** (full path on the deployed site: `https://bloom-coffee-7rbj.onrender.com/admin/login`).

**Demo credentials for this reviewer deployment** (use these if they match how the demo was seeded):

| Field | Value |
| ------ | ------- |
| **Email** | `admin@bloom.coffee` |
| **Password** | `test1234` |




There is **no public sign-up** for admin — reviewers must rely on seeded creds or the console snippet above.

---

## Tech stack

- **Ruby on Rails** `~> 8.0`, **Ruby** `3.3.7`
- **PostgreSQL** (development, test, production)
- **Hotwire** (Turbo + Stimulus), **importmap**
- **Tailwind CSS** (tailwindcss-rails)
- Tests: **RSpec**, **Factory Bot**
- Deploy: **Render**

## What’s implemented

Aligned with **`STORIES.md`** where applicable:

1. **Admin auth** — Email + password session (`Admin`, `has_secure_password`); protected `/admin` routes.
2. **Admin drinks CRUD** — Turbo-backed flows under **`/admin/drinks`**.
3. **Admin add-ons CRUD** — **`/admin/add_ons`**.
4. **Customer menu + cart** — Menu, line totals (Stimulus), cart quantities, footer nav.
5. **Orders** — Pickup name, confirmation page, orders index wired to recent session history.

## Decisions and trade-offs

- **Cart** — `Order` rows with `in_progress` vs `submitted`; `session[:order_id]` pins the anonymous draft (`CartConcern`).
- **Admin** — Namespace + `Admin::BaseController`; no OAuth or password reset in scope.
- **Deletes** — `Drink` and `AddOn` use **`restrict_with_exception`** when referenced by order lines so catalog deletes don’t corrupt historical totals.

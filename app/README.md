# Bloom Coffee

## Live app

**URL:** [https://bloom-coffee-7rbj.onrender.com/](https://bloom-coffee-7rbj.onrender.com/)

Render’s free tier spins down when idle; the **first request after sleep** can take on the order of **30–60 seconds** while the service wakes up.

## Admin access

- **Path:** `/admin/login`

**Demo credentials**:

 **Email** : `admin@bloom.coffee` 
 **Password** : `test1234`

## Tech stack

- **Ruby on Rails** `~> 8.0`, **Ruby** `3.3.7`
- **PostgreSQL** (development, test, production)
- **Hotwire** (Turbo + Stimulus), **importmap** 
- **Tailwind**
- Test: **RSpec**, **Factory Bot** 
- Deploy: Render

## What’s implemented

Aligned with **`STORIES.md`**:

1. **Admin auth** — simple **email + password** session sign-in (`Admin` + `has_secure_password`); logout and protected `/admin` routes (no OAuth or self-service sign-up).
2. **Admin drinks CRUD** — Turbo-backed forms under `/admin/drinks`.
3. **Admin add-ons CRUD** — under `/admin/add_ons`.
4. **Customer menu + cart** — menu index/show, line totals (Stimulus), cart with quantities and running total, responsive layout and footer nav.
5. **Orders** — submit with pickup name, confirmation page with line items and total; orders index shows the latest order for the session.

## Decisions and trade-offs

- **Cart** — Implemented as an `Order` with status `in_progress` vs `submitted`. `CartConcern` keeps `session[:order_id]` so the draft cart survives browser/server restarts and we reuse one model for draft and completed orders. Trade-off: abandoned `in_progress` rows can linger unless we prune them later.
- **Admin** — Single `Admin` model with `has_secure_password`; `Admin::BaseController` runs `require_admin` on namespaced controllers. Session login only (no sign-up / reset in scope).
- **Deleting drinks** — `Drink` uses `has_many :order_items, dependent: :restrict_with_exception`, so a drink that already appears on an `OrderItem` cannot be destroyed—admins see an error instead of silently breaking past orders.


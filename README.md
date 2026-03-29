# Bloom Coffee — Candidate Code Exercise

Welcome! This repo contains the exercise brief for **Bloom Coffee**, a small coffee-shop ordering app. Your job is to implement the stories below, deploy the app somewhere we can use it, and open a pull request. You may use any language, framework, or tools (including AI). We care about clarity, structure, and that it runs.

**Key docs:** [STORIES.md](STORIES.md) (stories & acceptance criteria) · [RUBRIC.md](RUBRIC.md) (what we look for when reviewing)

---

## What we expect

1. **Fork this repo** and implement the stories in `STORIES.md`.
2. **Deploy** the app to a URL we can open (e.g. Vercel, Railway, Fly.io, your own server). No payment processing required.
3. The **customer-facing flow** (menu, order, confirmation) should be **mobile-friendly**: usable and readable on both phone and desktop. Admin can be desktop-only if you prefer.
4. **Open a pull request** back to our repo. In the PR description, include: **link to your deployed app**, **admin login credentials** (or how to create an admin), and optionally your **tech stack** and any **trade-offs or decisions** you want us to know about.
5. Our engineers will review your code and deployment. If we move forward, **Phase 2** will be a pairing session where you propose one or two features that would add business value to Bloom Coffee, we'll do a short planning together, and then you'll implement and deploy those with us.

**Time:** We've scoped this for about **2–3 hours** of focused work. You're welcome to take longer if you'd like—we'd rather you finish at your pace than feel rushed. We've kept the scope intentional so you can complete it without an overwhelming commitment. Please submit within one week of receiving this exercise.

**Questions?** Email Mike Benner at michael.b@bloomgrowth.com

---

## What we look for

Our engineers use a rubric when reviewing your submission. You can see what we evaluate and how we give feedback here: **[RUBRIC.md](RUBRIC.md)**.

---

## How to run locally

#### macOS (from scratch)

**1. Install Homebrew** (if you don't have it):

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**2. Install rbenv, Ruby, and PostgreSQL:**

```bash
brew install rbenv ruby-build postgresql@16
```

Add rbenv to your shell (follow the instructions from `rbenv init`, or add to `~/.zshrc`):

```bash
echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc
source ~/.zshrc
```

Install the required Ruby version and Bundler:

```bash
rbenv install 3.3.7      # matches .ruby-version
rbenv global 3.3.7
gem install bundler
```

**3. Start PostgreSQL:**

```bash
brew services start postgresql@16
```

**4. Set up and run the app:**

```bash
bundle install
bin/rails db:prepare   # creates DBs and runs migrations
bin/rails db:seed      # creates the default admin user (see below)
bin/rspec              # run the test suite
bin/dev                # Foreman: Rails server + Tailwind file watcher (recommended in development)
# or: bin/rails server   # run `bin/rails tailwindcss:watch` in another terminal for CSS changes
```

#### Linux

**Prerequisites:** Ruby (see `.ruby-version`) via [rbenv](https://github.com/rbenv/rbenv) or [asdf](https://asdf-vm.com/), Bundler, and PostgreSQL running locally. Then run the same setup commands from step 4 above.

#### Docker (any OS, including Windows)

The easiest way to run the project on any platform is with [Docker Desktop](https://www.docker.com/products/docker-desktop/):

```bash
docker compose up --build
```

This starts PostgreSQL and the Rails server in containers. On the first run it creates the database, runs migrations, and seeds the admin user. Then open [http://localhost:3000](http://localhost:3000).

To run tests inside the container:

```bash
docker compose exec web bin/rspec
```

To stop everything:

```bash
docker compose down
```

#### Windows (without Docker)

Alternatively, use [WSL 2](https://learn.microsoft.com/en-us/windows/wsl/install) with an Ubuntu distribution. Once inside WSL:

1. Install Ruby via [rbenv](https://github.com/rbenv/rbenv) or [asdf](https://asdf-vm.com/)
2. Install PostgreSQL: `sudo apt install postgresql libpq-dev` and start the service: `sudo service postgresql start`
3. Then run the same commands as macOS/Linux above

#### Open the app

Navigate to [http://localhost:3000](http://localhost:3000) (port may differ if `bin/dev` assigns another).

**Admin login:** After `bin/rails db:seed`, sign in at `/admin/login` with:

- **Email:** `admin@bloomcoffee.com`
- **Password:** `INeedCaffeine!123`

Override with `SEED_ADMIN_EMAIL` and `SEED_ADMIN_PASSWORD` environment variables when seeding if you prefer different credentials.

### Deploy

Deployed on [Render](https://render.com/) using the included `render.yaml` Blueprint (web service + PostgreSQL).

**Live URL:** [https://bloom-coffee.onrender.com/](https://bloom-coffee.onrender.com/)

> **Note:** The Render free tier spins down after inactivity. The first request may take 30–60 seconds to respond.

### Tech stack

- **Ruby on Rails** 8.x (single app at the repository root)
- **PostgreSQL** (development, test, production)
- **Hotwire:** [Turbo Rails](https://turbo.hotwired.dev/) + [Stimulus](https://stimulus.hotwired.dev/) via [importmap-rails](https://github.com/rails/importmap-rails)
- **CSS:** [Tailwind CSS](https://tailwindcss.com/) v4 via [tailwindcss-rails](https://github.com/rails/tailwindcss-rails)
- **Authentication:** [Devise](https://github.com/heartcombo/devise) (database authenticatable, rememberable)
- **Authorization:** [Pundit](https://github.com/varvet/pundit) (role-based admin gate via `UserPolicy`)
- **Tests:** [RSpec](https://github.com/rspec/rspec-rails) + [Factory Bot](https://github.com/thoughtbot/factory_bot_rails) + [Capybara](https://github.com/teamcapybara/capybara) (request, model, policy, and system specs)

### Environment variables

| Variable | Required | Description |
|---|---|---|
| `DATABASE_URL` | Production | PostgreSQL connection string (set by Render) |
| `RAILS_MASTER_KEY` | Production | Decrypts `credentials.yml.enc` |
| `SEED_ADMIN_EMAIL` | No | Override default admin email (default: `admin@bloomcoffee.com`) |
| `SEED_ADMIN_PASSWORD` | No | Override default admin password (default: `INeedCaffeine!123`) |
| `MAILER_HOST` | Production | Host for mailer-generated URLs |

---

## Repo structure

```
/
├── app/
│   ├── controllers/
│   │   ├── admin/           # Admin namespace (BaseController gate, Drinks, AddOns)
│   │   ├── cart/            # Cart::ItemsController (add/update/remove items)
│   │   ├── concerns/        # CartConcern (session-backed current_order)
│   │   ├── cart_controller  # Cart show (order summary)
│   │   ├── menu_controller  # Public menu (index + customize drink)
│   │   ├── orders_controller# Submit order + confirmation page
│   │   └── home_controller  # Landing page
│   ├── models/              # User, Drink, AddOn, Order, OrderItem, OrderItemAddOn
│   ├── policies/            # UserPolicy (admin access gate), ApplicationPolicy
│   ├── views/               # ERB templates with Tailwind CSS
│   └── javascript/          # Stimulus controllers (line-total preview)
├── config/
│   └── routes.rb            # RESTful routes: menu, cart, orders, admin namespace
├── db/
│   ├── migrate/             # All migrations
│   ├── schema.rb            # Current schema
│   └── seeds.rb             # Admin user bootstrap
├── spec/                    # RSpec: models, requests, policies, system
├── render.yaml              # Render Blueprint (IaC)
├── STORIES.md               # Stories & acceptance criteria
└── RUBRIC.md                # Evaluation rubric
```

---

## Stories

See **[STORIES.md](STORIES.md)** for the five stories and acceptance criteria. Implement all of them; the order in the file is a suggested sequence.

Good luck — we're looking forward to seeing what you build.

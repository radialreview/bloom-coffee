# Bloom Coffee

Ruby backend + React frontend implementation of the Bloom Coffee exercise.

## Current status

- Story 1 implemented: admin authentication with protected admin route and logout.
- Stories 2-5 pending.

## Tech stack

- Backend: Ruby + Sinatra API (`backend/`)
- Frontend: React + Vite (`frontend/`)

## Admin credentials

- Email: `admin@bloom.coffee`
- Password: `password123`

You can override these with environment variables in `backend/.env`.

## Prerequisites

- Node.js 20+ (frontend)
- Ruby 3.1+ and Bundler (backend)

## Local setup

### 1) Backend

```bash
cd backend
cp .env.example .env
bundle install
bundle exec rackup -p 4567
```

Backend runs on `http://localhost:4567`.

### 2) Frontend

```bash
cd frontend
cp .env.example .env
npm install
npm run dev
```

Frontend runs on `http://localhost:5173`.

## Story 1 manual test checklist

1. Open `http://localhost:5173/admin/login`.
2. Enter valid credentials (`admin@bloom.coffee` / `password123`) and click **Sign in**.
3. Confirm redirect to `/admin/dashboard` and see authenticated admin page.
4. Open an incognito window and directly visit `/admin/dashboard`; confirm redirect to `/admin/login`.
5. Back on authenticated session, click **Log out**.
6. Confirm redirect to login and that revisiting `/admin/dashboard` now redirects to login.
7. On login page, try invalid password and confirm visible error message.

## API endpoints for Story 1

- `POST /api/v1/admin/login`
- `GET /api/v1/admin/session` (protected)
- `POST /api/v1/admin/logout` (protected)

## Exercise docs

- Stories: [STORIES.md](STORIES.md)
- Rubric: [RUBRIC.md](RUBRIC.md)

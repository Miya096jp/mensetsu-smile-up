# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this app is

「面接スマイルup!」 — a no-signup web app that gives job seekers an AI critique of their
facial expression and posture during a mock interview. The browser records the user via
webcam, extracts two JPEG stills, and sends them to Gemini for a non-verbal-communication
critique. **No image or video is ever persisted server-side** — this privacy guarantee is a
core product promise, not an implementation detail. There is no database schema
(`db/schema.rb` is empty) and no user accounts.

## Development

Everything runs in Docker Compose. The `web` service runs `bin/dev` (Procfile.dev: Puma +
`tailwindcss:watch`).

- Start: `docker compose up` (first time: `docker compose build`), then http://localhost:3000
- Requires `.env` with `GEMINI_API_KEY` (copy from `.env.example`)
- Run any command in the container: `docker compose exec web <cmd>`

### Tests (RSpec — not minitest)

The test suite is RSpec, and CI (`.github/workflows/ci.yml`) is the source of truth.

- All non-system specs: `docker compose exec web bundle exec rspec --exclude-pattern "spec/system/**/*_spec.rb"`
- System specs (Capybara + Selenium): `docker compose exec web bundle exec rspec spec/system/`
- Single file / example: `docker compose exec web bundle exec rspec spec/requests/diagnoses_spec.rb:13`
- LLM calls are stubbed with `RubyLLM::Test.stub_response(...)` (see `spec/services/llm/diagnose_impression_spec.rb`)
- `Rack::Attack` is force-disabled in specs (`spec/rails_helper.rb`)

### Lint

- Ruby: `docker compose exec web bin/rubocop` (rubocop-rails-omakase)
- JS: `biome check` (or `biome ci .` as in CI). Biome is installed separately (`brew install biome`), not via npm.
- CI also runs Brakeman, `bundler-audit`, and `bin/importmap audit`.

## Architecture

### Frontend: one page, Stimulus-driven step machine

The main/interactive route is `root "diagnoses#new"` (`app/views/diagnoses/new.html.slim`,
Slim templates throughout); `PagesController` also serves static `terms`/`privacy` pages.
No Turbo navigation — the whole diagnosis flow is fullscreen overlay `<div>`s toggled by
Stimulus. JS is delivered via importmap (no bundler); Tailwind via tailwindcss-rails.

- `step_controller.js` — orchestrator. Holds `currentStep` and transitions
  `lp → cameraCheck → guide → diagnosis`, showing a `deviceError` panel if
  `getUserMedia` fails. Uses Stimulus **outlets** to call into the camera-check and
  diagnosis controllers (e.g. `startCamera`, `reset`, `teardown`).
- `camera_check_controller.js` — framing preview before diagnosis.
- `guide_controller.js` — "don't show this again" checkbox, persisted in `localStorage.saveKey`.
- `diagnosis_controller.js` — the core loop: plays a random interviewer video from
  `public/videos/`, after `prepDuration` captures `totalShots` (2) frames by drawing the
  webcam `<video>` onto a 300×400 `<canvas>` and `toBlob("image/jpeg", 0.8)`, then POSTs
  them as `photos[]` multipart to `/diagnoses` with the CSRF token, and renders the JSON
  `content` (or error `message`) into the feedback panel.

Every failure path in `diagnosis_controller.js` (interviewer-video playback error, capture
error, fetch/POST error, and — via a `visibilitychange` listener registered in `connect()`
— the tab being hidden mid-diagnosis) recovers the same way: `teardown()` → `startCamera()`
→ `reset(message)`. Reuse this pattern rather than inventing new error handling; `isRunning`
tracks whether a diagnosis is in flight so the visibility check only fires mid-run, and
`disconnect()` tears down the camera and removes the listener.

**Slim gotcha:** in `new.html.slim`, boolean `<video>` attributes must be written as
`autoplay=true playsinline=true muted=true`, not bare — a bare boolean attribute following a
quoted attribute (e.g. a `data-*="..."`) is serialized as literal text instead of an HTML
attribute. `playsinline=true` on the interviewer `<video>` is required to stop iOS Safari
from taking over with native fullscreen playback (which froze the preview and caused blank
captures) — don't remove it.

### Backend: validate → prompt → Gemini

`POST /diagnoses` (`resources :diagnoses, only: [:create]`) is the only non-static endpoint.

1. `DiagnosesController#create` builds `DiagnosisRequest` (`app/models/diagnosis_request.rb`)
   — an `ActiveModel::Model` form object, **not** ActiveRecord. It enforces exactly 2
   photos, each `image/jpeg` (checked via `Marcel::MimeType`), each `< 150.kilobytes`.
   Invalid → `422` JSON `{ message: "不正なリクエストです" }`.
2. `Llm::DiagnoseImpression.call(photos:)` (`app/services/llm/`) reads the system prompt
   from `app/prompts/diagnose_impression.md`, calls `RubyLLM.chat(model: "gemini-2.5-flash")`
   with the images, and raises `InvalidResponse` if the reply exceeds `MAX_LENGTH` (500).
3. Errors are mapped to user-facing JSON + status in the controller `rescue` chain:
   RubyLLM rate/server errors and `InvalidResponse` → `503`; anything else → `500`.
   All branches log with a `[Tag]` prefix.

RubyLLM retry/backoff config lives in `config/initializers/ruby_llm.rb`
(`max_retries: 1`, `retry_backoff_factor: 3`, `request_timeout: 30`). The prompt file itself
contains prompt-injection defenses (it tells the model to never interpret text visible in
the images as instructions) — preserve that intent when editing it.

### Abuse protection

`config/initializers/rack_attack.rb` throttles `POST /diagnoses` with three limits: **3
requests / minute / IP**, a per-IP daily cap (`DIAGNOSES_IP_DAILY_LIMIT`, 10/day), and a
global daily cap across all IPs (`DIAGNOSES_DAILY_LIMIT`, 100/day).

## Deployment

Push to `main` → GitHub Actions `cd.yml` runs CI, then `kamal deploy` to a Sakura VPS,
image on `ghcr.io`, served at https://mensetsu-smile-up.com. Needs `RAILS_MASTER_KEY`,
`GEMINI_API_KEY`, `SSH_PRIVATE_KEY` repo secrets. Config in `config/deploy.yml`, which also
caps the Kamal proxy's `max_request_body` at 1MB (comfortably above the 2×150KB photo
upload). `config/environments/production.rb` sets `force_ssl`/`assume_ssl`.

## Stack notes

Ruby 4.0.5 / Rails 8.1. SQLite + the solid_* gems are present from the Rails 8 default
stack but there are no app tables. `allow_browser versions: :modern` in
`ApplicationController` gates old browsers.

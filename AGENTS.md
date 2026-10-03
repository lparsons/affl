# The Art of Fantasy Football League (AFFL) - Project Context

## Project Overview

The Art of Fantasy Football League (AFFL) website is a Jekyll-based static site designed to showcase league information, constitution rules, history, record book, and season schedule. It features live integration with the Sleeper API and automated milestone calendar calculations.

- **Main Technologies:** Jekyll 4, Ruby 3.2, Liquid, Sass, Sleeper API, GitHub Actions.
- **Hosting Target:** GitHub Pages (`https://lparsons.github.io/affl/`).
- **CI/CD:** `.github/workflows/deploy.yml` (Automated build & weekly Sleeper sync every Tuesday).

## Core Architecture

- **Data Integration & Plugins:**
  - `_plugins/league_calendar.rb`: Automatically calculates NFL Kickoff (Thursday after Labor Day) and all subsequent milestone dates (Keepers, Draft, Claims, Trade Deadline, Playoffs, Pro Bowl). Detects anomalies and displays warning alerts if dates are suspicious. Supports overrides via `_config.yml`.
  - `_plugins/sleeper_generator.rb`: Fetches historical seasons and career team profiles via Sleeper API during build; generates all-time record books and team profile pages. Enforces completed-week thresholds (`last_scored_leg` / standings games played) so in-progress and unplayed matchups never pollute season superlatives, career logs, nail-biters, or shootouts.
  - `_scripts/update_standings.rb`: Standalone script to pull live standings and matchups for all seasons from Sleeper and write JSON data to `_data/seasons/` (including `last_scored_leg`).
- **Pages & Components:**
  - `index.md`: Dynamic homepage dashboard with upcoming milestone countdown banner and season phase switching (`predraft`, `regular_season`, `playoffs`, `offseason`).
  - `rules.md`: Complete league constitution and governance rules.
  - `schedule.md`: Interactive milestone timeline and recurring in-season deadlines.
  - `seasons.md`: Interactive seasons dashboard with podiums, awards, historical standings, and matchup showcases (filtered to completed weeks with valid scores).
  - `records.md`: All-time record book and hall of champions.
  - `about.md`: League mission, roster format, scoring summary, and contact information.

## Recent Updates & Bug Fixes

- **In-Progress Week & 0–0 Matchup Filtering (Seasons Dashboard):**
  - Resolved issue where active/incomplete weeks (e.g., Week 4 with 0–0 scores) populated "Closest Nail-Biters" and "Wildest Shootouts".
  - `_plugins/sleeper_generator.rb` now restricts season superlative calculations and career matchups strictly to completed weeks (`completed_weeks_limit`) and ignores unplayed `0 <= points` matchups.
  - `seasons.md` UI safely validates `winner_points > 0 && loser_points > 0 && total_points > 0` before rendering matchup cards and single-game highs.
  - `_scripts/update_standings.rb` persists Sleeper's `last_scored_leg` to season JSONs.

## Building and Running Locally

- **Install Dependencies:** `bundle install`
- **Serve Locally:** `.\bin\jekyll.cmd serve` or `bundle exec jekyll serve` (Accessible at `http://localhost:4000`).
- **Build Site:** `.\bin\jekyll.cmd build` or `bundle exec jekyll build`
- **Update Sleeper Data:** `ruby _scripts\update_standings.rb` (or `.\update_affl.bat`)
- **Lint Markdown:** `npx markdownlint-cli "**/*.md"` (Auto-fix with `--fix`)
- **Enable Git Hook:** `git config core.hooksPath .githooks`

---

## 📋 Sleeper App Configuration Checklist (For Commissioner)

When setting up the 2026 season in the Sleeper App/Web:

- [ ] **Draft Date & Time:** Schedule slow snake draft for **Sunday, August 30, 2026 @ 9:00 AM**.
- [ ] **Keeper Deadline:** Set to **"1 week before draft"** (resolves to **August 23, 2026** for the Aug 30 draft).
- [ ] **Max Keepers:** Set to **1 Keeper** per team (Round 1 pick forfeited).
- [ ] **Draft Order:**
  - Assign non-playoff teams picks 1–6 in reverse order of lower bracket finish (12th place gets Pick 1, 11th gets Pick 2, ..., 7th gets Pick 6).
  - Assign Toilet Bowl Winner Pick **2.01** (or 1.01 if keeping no player) in the first round post-keepers.
  - Assign playoff teams picks 7–12 in reverse order of championship bracket finish (6th place gets Pick 7, 5th gets Pick 8, ..., 1st place gets Pick 12).
- [ ] **Divisions:** Confirm 2 Divisions (**Yin** and **Yang**), 6 teams each.
- [ ] **Playoff Schedule:** 6 Teams, 3 Weeks (Weeks 15, 16, and 17; Top 2 seeds get 1st-round byes).
- [ ] **Trade Deadline:** Set to **Week 13**.
- [ ] **LeagueSafe:** Create LeagueSafe pool for 2026 dues and post link in Sleeper chat.
- [ ] **Dues Enforcement:** Verify all 12 teams are paid in full or arranged prior to the NFL season opener kickoff; apply Sleeper transaction freeze to any unpaid managers.

---

## 🎯 Next Steps on Other Computer

1. Clone / Pull repository: `git pull origin main`
2. Run `bundle install` (if Ruby/bundler installed).
3. Update Sleeper data: `.\update_affl.bat` or `ruby _scripts\update_standings.rb`.
4. Run local server: `.\bin\jekyll.cmd serve` and verify season dashboard and completed weeks.

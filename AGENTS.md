# The Art of Fantasy Football League (AFFL) - Project Context

## Project Overview
The Art of Fantasy Football League (AFFL) website is a Jekyll-based static site designed to showcase league information, constitution rules, history, record book, and season schedule. It features live integration with the Sleeper API and automated milestone calendar calculations.

- **Main Technologies:** Jekyll 4, Ruby 3.2, Liquid, Sass, Sleeper API, GitHub Actions.
- **Hosting Target:** GitHub Pages (`https://lparsons.github.io/affl/`).
- **CI/CD:** `.github/workflows/deploy.yml` (Automated build & weekly Sleeper sync every Tuesday).

## Core Architecture
- **Data Integration & Plugins:**
  - `_plugins/league_calendar.rb`: Automatically calculates NFL Kickoff (Thursday after Labor Day) and all subsequent milestone dates (Keepers, Draft, Claims, Trade Deadline, Playoffs, Pro Bowl). Detects anomalies and displays warning alerts if dates are suspicious. Supports overrides via `_config.yml`.
  - `_plugins/sleeper_generator.rb`: Fetches historical seasons and career team profiles via Sleeper API during build; generates all-time record books and team profile pages.
  - `_scripts/update_standings.rb`: Standalone script to pull live standings and matchups for all seasons from Sleeper and write JSON data to `_data/seasons/`.
- **Pages & Components:**
  - `index.md`: Dynamic homepage dashboard with upcoming milestone countdown banner and season phase switching (`predraft`, `regular_season`, `playoffs`, `offseason`).
  - `rules.md`: Complete league constitution and governance rules.
  - `schedule.md`: Interactive milestone timeline and recurring in-season deadlines.
  - `seasons.md`: Interactive seasons dashboard with podiums, awards, and historical standings.
  - `records.md`: All-time record book and hall of champions.
  - `about.md`: League mission, roster format, scoring summary, and contact information.

## Building and Running Locally
- **Install Dependencies:** `bundle install`
- **Serve Locally:** `.\bin\jekyll.cmd serve` or `bundle exec jekyll serve` (Accessible at `http://localhost:4000`).
- **Build Site:** `.\bin\jekyll.cmd build` or `bundle exec jekyll build`
- **Update Sleeper Data:** `ruby _scripts\update_standings.rb` (or `.\update_affl.bat`)

---

## 📋 Sleeper App Configuration Checklist (For Commissioner)
When setting up the 2026 season in the Sleeper App/Web:
- [ ] **Keeper Deadline:** Set Keeper Deadline to **August 23, 2026** (or 1 week prior to draft).
- [ ] **Max Keepers:** Set to **1 Keeper** per team (Round 1 pick forfeited).
- [ ] **Draft Date & Time:** Schedule slow snake draft for **Sunday, August 30, 2026 @ 6:00 PM**.
- [ ] **Draft Order:** 
  - Assign non-playoff teams picks 1–6 in reverse order of regular season record.
  - Assign Toilet Bowl Winner Pick **2.01** (or 1.01 if keeping no player).
  - Assign playoff teams picks 7–12 based on playoff finish.
- [ ] **Divisions:** Confirm 2 Divisions (**Yin** and **Yang**), 6 teams each.
- [ ] **Playoff Schedule:** 6 Teams, 3 Weeks (Weeks 15, 16, and 17; Top 2 seeds get 1st-round byes).
- [ ] **Trade Deadline:** Set to **Week 13**.
- [ ] **LeagueSafe:** Create LeagueSafe pool for 2026 dues and post link in Sleeper chat.

---

## 🎯 Next Steps on Other Computer
1. Clone / Pull repository: `git pull origin main`
2. Run `bundle install` (if Ruby/bundler installed).
3. Monitor owner responses to "I'm in" roll call.
4. Input keeper designations and finalized draft order into Sleeper once keepers lock on August 23.


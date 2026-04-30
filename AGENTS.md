# The Art of Fantasy Football League (AFFL) - Project Context

## Project Overview
The Art of Fantasy Football League (AFFL) website is a Jekyll-based static site designed to showcase league information, standings, rules, and history. It features live integration with the Sleeper API to automatically update standings and statistical leaders.

- **Main Technologies:** Jekyll, Ruby, Liquid, Sleeper API.
- **Theme:** `minima` (v2.5).
- **Hosting Target:** GitHub Pages or similar static hosting.

## Core Architecture
- **Data Integration:** 
  - `_scripts/update_standings.rb`: A standalone Ruby script that fetches data from Sleeper and overwrites `standings.md`.
  - `_plugins/sleeper_generator.rb`: A Jekyll generator that fetches Sleeper data during the build process and makes it available via `site.data['standings']` and generates `standings_data.json`.
  - `_scripts/sleeper_data.rb`: Shared API logic for interacting with Sleeper.
- **Content:** Managed through Markdown files in the root (`index.md`, `about.md`, `standings.md`, etc.).
- **Styles:** Custom Sass in `_sass/` and standard Minima overrides.

## Building and Running
The project is configured for a Windows environment with Ruby 3.2.

### Prerequisites
- **Ruby:** 3.2+ (expected at `C:\Ruby32-x64\bin\ruby.exe`).
- **Bundler:** Installed via `gem install bundler`.

### Key Commands
- **Install Dependencies:** `bundle install`
- **Full Update & Build:** `.\update_affl.bat` (Updates standings and builds the site).
- **Update Standings Only:** `ruby _scripts\update_standings.rb`
- **Serve Locally:** `.\bin\jekyll.cmd serve` (Accessible at `http://localhost:4000`).
- **Build Site:** `.\bin\jekyll.cmd build`

## Development Conventions
- **Configuration:** All league-specific settings (League ID, Season, Name) are stored in `_config.yml`.
- **Dynamic Content:** Avoid manually editing `standings.md` as it is overwritten by `_scripts/update_standings.rb`.
- **Custom Logic:** 
  - Add new API-driven features to `_scripts/sleeper_data.rb` first.
  - Use `_plugins/` for logic that needs to run during every Jekyll build.
- **Environment:** If Ruby commands fail, ensure `C:\Ruby32-x64\bin` is in your PATH or prefix commands with the full path to `ruby.exe`.

## Key Files & Directories
- `_config.yml`: Main Jekyll configuration and league variables.
- `_scripts/`: Ruby scripts for data synchronization.
- `_plugins/`: Custom Jekyll plugins (Generator for Sleeper data).
- `standings.md`: Automatically updated standings page.
- `rules.md`: League rules and constitution.
- `Gemfile`: Ruby dependencies.
- `update_affl.bat`: Primary workflow script for Windows.

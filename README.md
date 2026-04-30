# The Art of Fantasy Football League (AFFL) Website

Official Jekyll-based website for The Art of Fantasy Football League (AFFL), hosted on Sleeper with live data integration.

## 🏈 Features

- **Live Sleeper Integration**: Automatically pulls standings, team data, and league info
- **Real-time Updates**: Current standings with playoff picture and statistical leaders
- **Responsive Design**: Mobile-friendly Jekyll site with Minima theme
- **Easy Updates**: Simple scripts to refresh league data

## 🚀 Quick Start

### Prerequisites

**Ruby 3.2+ with MSYS2** (Windows)
- Install via: `winget install RubyInstallerTeam.RubyWithDevKit.3.2`
- Adds Ruby to PATH automatically

### Installation

1. Navigate to the project directory
2. Install dependencies:
   ```bash
   $env:PATH = "C:\Ruby32-x64\bin;" + $env:PATH
   bundle install
   ```

### 📊 Updating League Data

#### Method 1: One-Click Update (Recommended)
```bash
.\update_affl.bat
```

#### Method 2: Manual Commands
```bash
# Set Ruby path for current session
$env:PATH = "C:\Ruby32-x64\bin;" + $env:PATH

# Update standings from Sleeper
ruby _scripts\update_standings.rb

# Build the site
.\bin\jekyll.cmd build

# Serve locally
.\bin\jekyll.cmd serve
```

#### Method 3: View Raw Data
```bash
$env:PATH = "C:\Ruby32-x64\bin;" + $env:PATH
ruby _scripts\sleeper_data.rb
```

### 🌐 Running the Site

```bash
$env:PATH = "C:\Ruby32-x64\bin;" + $env:PATH
.\bin\jekyll.cmd serve
```

Site will be available at `http://localhost:4000`

## 🔗 Sleeper API Integration

### Current League Configuration
- **League ID**: `1124837607272898560` (configured in `_config.yml`)
- **Platform**: Sleeper
- **Season**: 2024
- **Teams**: 12

### What Gets Updated Automatically

#### Standings Page (`standings.md`)
- **Current standings table** with rank, team name, manager, record, points for/against
- **Playoff picture** showing top 6 playoff teams and bubble teams
- **Statistical leaders**:
  - Highest scoring teams
  - Best records
  - Fewest points against (luckiest teams)
- **Last updated timestamp**

#### Available Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `_scripts/sleeper_data.rb` | View raw league data | `ruby _scripts\sleeper_data.rb` |
| `_scripts/update_standings.rb` | Update standings page | `ruby _scripts\update_standings.rb` |
| `update_affl.bat` | One-click update | `.\update_affl.bat` |

### Current League Status

**Top Teams** (as of last update):
1. **Kolners** (kolners) - 10-4, 1823.00 PF
2. **Birants** (maheshbiradar) - 10-4, 1733.00 PF
3. **Desert Scorpions** (CodeBrewer) - 9-5, 1783.00 PF

**Playoff Picture**: Top 6 teams automatically qualify

### Customizing for Your League

1. **Find your Sleeper League ID**:
   - Go to your league in Sleeper app/website
   - Copy the number from the URL: `https://sleeper.app/leagues/YOUR_LEAGUE_ID/team`

2. **Update `_config.yml`**:
   ```yaml
   sleeper_league_id: "YOUR_LEAGUE_ID_HERE"
   ```

3. **Run the update script**:
   ```bash
   ruby _scripts\update_standings.rb
   ```

### Troubleshooting

**Common Issues**:
- **"nvim not found"**: Neovim installed at `C:\Program Files\Neovim\bin\nvim.exe`
- **"ruby not found"**: Use full path `C:\Ruby32-x64\bin\ruby.exe`
- **Gem errors**: Run `bundle install` first
- **API errors**: Check your league ID in `_config.yml`

**Ruby Path Issues**:
If Ruby commands don't work, set the path:
```bash
$env:PATH = "C:\Ruby32-x64\bin;" + $env:PATH
```

## ✏️ Editing Files

### Available Editors

**Neovim** (Installed and configured):
```bash
nvim _config.yml          # Edit main config
nvim standings.md         # Edit standings page
nvim index.md             # Edit home page
```

**Other Options**:
```bash
notepad _config.yml       # Windows Notepad
code .                    # VS Code (if installed)
start _config.yml         # Default program
```

### Basic Neovim Commands
- `i` - Enter insert mode (start typing)
- `Esc` - Exit insert mode
- `:w` - Save file
- `:q` - Quit
- `:wq` - Save and quit
- `:q!` - Quit without saving

## Site Structure

```
├── _config.yml          # Jekyll configuration
├── _posts/              # Blog posts (future league updates)
├── _layouts/            # HTML templates
├── _includes/           # Reusable HTML components
├── _sass/               # Sass stylesheets
├── assets/              # CSS, JS, images
├── index.md             # Home page
├── about.md             # About page
├── standings.md         # Current standings
├── schedule.md          # Season schedule
├── rules.md             # League rules
├── history.md           # League history
└── README.md            # This file
```

## Customization

### League Information

Update the following in `_config.yml`:
- `title`: Your league name
- `description`: League description
- `current_season`: Current season year
- `league_name`: Full league name
- `league_abbreviation`: Short league name
- Contact information

### Content Updates

- **Standings**: Update `standings.md` with current standings
- **Schedule**: Update `schedule.md` with matchups and dates
- **Rules**: Customize `rules.md` with your league's specific rules
- **History**: Add past champions and memorable moments to `history.md`

### Styling

- Modify `_sass/` files for custom styling
- Add custom CSS to `assets/css/`
- Update `_layouts/` for custom page layouts

## Deployment Options

### GitHub Pages
1. Push to a GitHub repository
2. Enable GitHub Pages in repository settings
3. Site will be available at `https://username.github.io/repository-name`

### Netlify
1. Connect your repository to Netlify
2. Set build command: `bundle exec jekyll build`
3. Set publish directory: `_site`

### Other Hosting
Build the site with `bundle exec jekyll build` and upload the `_site` directory to your web host.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is open source and available under the [MIT License](LICENSE).

## Support

For questions about the league or website, contact the league commissioner or discuss in the Sleeper league chat.

---

**The Art of Fantasy Football League (AFFL)** - Where strategy meets passion!

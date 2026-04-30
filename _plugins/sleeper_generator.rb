require 'json'
require 'fileutils'

module Jekyll
  class SleeperMultiYearGenerator < Generator
    safe true
    priority :high

    def generate(site)
      # Calculate league state based on date
      calculate_league_state(site)

      seasons_dir = File.join(site.source, '_data', 'seasons')
      return unless Dir.exist?(seasons_dir)

      # Load all season files
      seasons = []
      Dir.glob(File.join(seasons_dir, '*.json')).each do |file|
        begin
          season_data = JSON.parse(File.read(file))
          
          # Identify winners
          if season_data['standings'] && !season_data['standings'].empty?
            season_data['champion'] = season_data['standings'].first
            season_data['toilet_bowl_winner'] = season_data['standings'].last
          end
          
          seasons << season_data
        rescue => e
          Jekyll.logger.warn "Error reading season file #{file}:", e.message
        end
      end

      # Sort seasons by year descending
      seasons.sort_by! { |s| -s['year'] }
      site.data['all_seasons'] = seasons

      # Generate pages for each season
      seasons.each do |season|
        site.pages << SeasonStandingsPage.new(site, site.source, "standings/#{season['year']}", season)
      end
    end

    private

    def calculate_league_state(site)
      now = Time.now
      draft_date_str = site.config['draft_date']
      return site.config['league_state'] = 'offseason' unless draft_date_str

      draft_date = Time.parse(draft_date_str)
      
      # Correctly handle year-end transitions
      # If draft_date is in the future, we are either in offseason or predraft
      # If draft_date is in the past, we are either in regular season or playoffs
      
      state = if now < draft_date
                # Pre-draft or Offseason
                prep_start = draft_date - (21 * 24 * 60 * 60) # 3 weeks
                if now >= prep_start
                  'predraft'
                else
                  'offseason'
                end
              else
                # Regular Season or Playoffs
                # Typically playoffs start around Week 14-15 (early Dec)
                playoff_start = Time.new(draft_date.year, 12, 1)
                offseason_end = Time.new(draft_date.year + 1, 1, 11)
                
                if now >= playoff_start && now < offseason_end
                  'playoffs'
                elsif now >= offseason_end
                  'offseason'
                else
                  'regular_season'
                end
              end

      site.config['league_state'] = state
      Jekyll.logger.info "Sleeper:", "Automated league state detected: #{state}"
    end
  end

  class SeasonStandingsPage < Page
    def initialize(site, base, dir, season)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.md'

      self.process(@name)
      
      self.data ||= {}
      self.data['layout'] = 'page'
      self.data['title'] = "#{season['year']} Standings"
      self.data['season'] = season
      
      # Build the content dynamically
      self.content = render_standings(season)
    end

    def render_standings(season)
      content = "# #{season['year']} AFFL Standings\n\n"
      content << "## Current Standings\n\n"
      content << "| Rank | Team Name | Manager | Record | Points For | Points Against |\n"
      content << "|------|-----------|---------|---------|------------|----------------|\n"

      season['standings'].each_with_index do |team, index|
        team_name = team['team_name'] || team['username']
        avatar_url = team['avatar'] ? "https://sleepercdn.com/avatars/thumbs/#{team['avatar']}" : "https://sleepercdn.com/images/v2/icons/player_default.webp"
        content << "| #{index + 1} | <img src=\"#{avatar_url}\" width=\"30\" height=\"30\" style=\"border-radius: 50%; vertical-align: middle; margin-right: 10px;\"> #{team_name} | #{team['username']} | #{team['record']} | #{sprintf('%.2f', team['points_for'])} | #{sprintf('%.2f', team['points_against'])} |\n"
      end

      content << "\n---\n\n"
      content << "*League: #{season['name']} (#{season['year']})*"
      content
    end
  end
end

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

      # Note: We no longer generate individual SeasonStandingsPage files
      # as the main /standings/ page is now dynamic.
    end

    private

    def calculate_league_state(site)
      now = Time.now
      draft_date_str = site.config['draft_date']
      return site.config['league_state'] = 'offseason' unless draft_date_str

      draft_date = Time.parse(draft_date_str)
      
      state = if now < draft_date
                prep_start = draft_date - (21 * 24 * 60 * 60) # 3 weeks
                if now >= prep_start
                  'predraft'
                else
                  'offseason'
                end
              else
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
end

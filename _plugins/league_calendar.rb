require 'date'
require 'time'
require 'yaml'
require 'net/http'
require 'json'
require 'uri'

module Jekyll
  class LeagueCalendarGenerator < Generator
    safe true
    priority :highest

    # Standard NFL Kickoff formula: The Thursday following the first Monday in September (Labor Day)
    def self.calculate_nfl_kickoff(year)
      first_day_of_september = Date.new(year, 9, 1)
      # cwday: 1 = Monday, 2 = Tuesday, ..., 7 = Sunday
      days_to_labor_day = (1 - first_day_of_september.cwday) % 7
      labor_day = first_day_of_september + days_to_labor_day
      # Thursday following Labor Day (+3 days)
      labor_day + 3
    end

    # Default Draft Date: The Sunday prior to kickoff (11 days prior at 6:00 PM)
    def self.calculate_default_draft_time(nfl_kickoff_date)
      draft_date = nfl_kickoff_date - 11
      Time.new(draft_date.year, draft_date.month, draft_date.day, 18, 0, 0)
    end

    def generate(site)
      warnings = []
      season_year = (site.config['current_season'] || Date.today.year).to_i

      # 1. Determine NFL Kickoff Date (Automatic calculation vs Config Override)
      calculated_nfl_start = self.class.calculate_nfl_kickoff(season_year)
      nfl_start_date = calculated_nfl_start
      nfl_is_overridden = false

      if site.config['nfl_season_start'] && !site.config['nfl_season_start'].to_s.strip.empty?
        begin
          parsed_start = Date.parse(site.config['nfl_season_start'].to_s)
          nfl_start_date = parsed_start
          nfl_is_overridden = true
          
          # Validation: Is the override suspicious?
          if parsed_start.month != 9
            warnings << "NFL Season Start override is in #{parsed_start.strftime('%B')} (expected September). Verify '_config.yml'."
          elsif parsed_start.cwday != 4
            warnings << "NFL Season Start override is on a #{parsed_start.strftime('%A')} (expected Thursday). Verify '_config.yml'."
          end
        rescue StandardError => e
          warnings << "Could not parse 'nfl_season_start' ('#{site.config['nfl_season_start']}'). Falling back to automatic date (#{calculated_nfl_start}). Error: #{e.message}"
          nfl_start_date = calculated_nfl_start
        end
      end

      # 2. Determine Draft Date & Time (Config Override vs Sleeper API vs Automatic calculation)
      calculated_draft_time = self.class.calculate_default_draft_time(nfl_start_date)
      draft_time = calculated_draft_time
      draft_is_overridden = false

      if site.config['draft_date'] && !site.config['draft_date'].to_s.strip.empty?
        begin
          draft_time = Time.parse(site.config['draft_date'].to_s)
          draft_is_overridden = true
        rescue StandardError => e
          warnings << "Could not parse 'draft_date' ('#{site.config['draft_date']}'). Falling back to automatic date (#{calculated_draft_time}). Error: #{e.message}"
          draft_time = calculated_draft_time
        end
      end

      draft_date = draft_time.to_date

      # Validation: Draft after season start?
      if draft_date > nfl_start_date
        warnings << "Draft Date (#{draft_date}) is set after NFL Season Kickoff (#{nfl_start_date}). Please check configuration."
      end

      # Expose resolved dates to Jekyll site config for other plugins/templates
      site.config['nfl_season_start'] = nfl_start_date.to_s
      site.config['draft_date'] = draft_time.strftime('%Y-%m-%d %H:%M:%S')
      site.config['nfl_start_is_auto'] = !nfl_is_overridden
      site.config['draft_date_is_auto'] = !draft_is_overridden

      # 3. Determine Keeper Deadline (Config Override vs 2 weeks before draft)
      calculated_keeper_due_date = draft_date - 14
      keeper_due_date = calculated_keeper_due_date

      if site.config['keeper_deadline'] && !site.config['keeper_deadline'].to_s.strip.empty?
        begin
          keeper_due_date = Date.parse(site.config['keeper_deadline'].to_s)
        rescue StandardError => e
          warnings << "Could not parse 'keeper_deadline' ('#{site.config['keeper_deadline']}'). Falling back to automatic date (#{calculated_keeper_due_date}). Error: #{e.message}"
          keeper_due_date = calculated_keeper_due_date
        end
      end

      if keeper_due_date > draft_date
        warnings << "Keeper Deadline (#{keeper_due_date}) is set after Draft Date (#{draft_date}). Please check configuration."
      end

      # 4. Calculate all other milestone events deterministically
      preseason_claims_date = nfl_start_date - 2
      trade_deadline_date = nfl_start_date + (13 * 7) - 1 # Conclusion of Week 13
      regular_season_end_date = nfl_start_date + (14 * 7) # Start of Week 15
      wildcard_date = nfl_start_date + (14 * 7)
      semifinals_date = nfl_start_date + (15 * 7)
      superbowl_date = nfl_start_date + (16 * 7)
      
      # First Sunday of February
      feb_first = Date.new(season_year + 1, 2, 1)
      days_to_sunday = (7 - feb_first.cwday) % 7
      pro_bowl_date = feb_first + days_to_sunday

      default_events = [
        {
          'id' => 'keeper_deadline',
          'title' => 'Keeper Selections Due',
          'tag' => 'Draft Prep',
          'category' => 'roster',
          'icon' => '🔒',
          'date' => keeper_due_date.to_s,
          'formatted_date' => keeper_due_date.strftime('%B %d, %Y'),
          'rule_ref' => '/rules/#4-keeper-rules',
          'description' => 'Managers must finalize designation of up to 1 keeper player (forfeits Round 1 pick).'
        },
        {
          'id' => 'draft_day',
          'title' => 'AFFL Slow Draft Begins',
          'tag' => 'Draft Day',
          'category' => 'draft',
          'icon' => '📋',
          'date' => draft_date.to_s,
          'time' => draft_time.strftime('%I:%M %p'),
          'formatted_date' => "#{draft_date.strftime('%B %d, %Y')} at #{draft_time.strftime('%I:%M %p')}",
          'rule_ref' => '/rules/#5-draft-order-determination',
          'description' => "Official #{season_year} AFFL draft kicks off in the Sleeper draft room with timer active."
        },
        {
          'id' => 'preseason_claims',
          'title' => 'Pre-Season Claims & Free Agency',
          'tag' => 'Waivers',
          'category' => 'roster',
          'icon' => '⚡',
          'date' => preseason_claims_date.to_s,
          'formatted_date' => preseason_claims_date.strftime('%B %d, %Y'),
          'rule_ref' => '/rules/#2-in-season-transaction--lineup-deadlines',
          'description' => 'First round pre-season waiver claims process. Unclaimed free agents become immediately available.'
        },
        {
          'id' => 'kickoff',
          'title' => 'NFL Kickoff (Week 1)',
          'tag' => 'Season Start',
          'category' => 'season',
          'icon' => '🏈',
          'date' => nfl_start_date.to_s,
          'formatted_date' => nfl_start_date.strftime('%B %d, %Y'),
          'rule_ref' => '/rules/#2-in-season-transaction--lineup-deadlines',
          'description' => 'Regular season begins with Thursday Night Football. Starting lineups lock at individual kickoff times.'
        },
        {
          'id' => 'trade_deadline',
          'title' => 'Trade Deadline',
          'tag' => 'Trading',
          'category' => 'roster',
          'icon' => '🤝',
          'date' => trade_deadline_date.to_s,
          'formatted_date' => trade_deadline_date.strftime('%B %d, %Y'),
          'rule_ref' => '/rules/#3-trading--draft-pick-exchanges',
          'description' => 'Conclusion of Week 13. Final deadline to complete player and draft pick trades for the season.'
        },
        {
          'id' => 'regular_season_end',
          'title' => 'Free Agency Lock / Regular Season Closes',
          'tag' => 'Playoff Lock',
          'category' => 'roster',
          'icon' => '🛑',
          'date' => regular_season_end_date.to_s,
          'formatted_date' => regular_season_end_date.strftime('%B %d, %Y'),
          'rule_ref' => '/rules/#8-general-season-calendar',
          'description' => 'Free agency closes before the first playoff game starts. Playoff rosters lock.'
        },
        {
          'id' => 'playoffs_wildcard',
          'title' => 'Wild Card Round (Week 15)',
          'tag' => 'Playoffs',
          'category' => 'playoffs',
          'icon' => '⚔️',
          'date' => wildcard_date.to_s,
          'formatted_date' => wildcard_date.strftime('%B %d, %Y'),
          'rule_ref' => '/rules/#6-playoff-structure',
          'description' => 'Seeds 3–6 clash in elimination matchups; Seeds 1 & 2 enjoy first-round byes. Toilet Bowl kicks off.'
        },
        {
          'id' => 'playoffs_semifinals',
          'title' => 'Conference Semifinals (Week 16)',
          'tag' => 'Playoffs',
          'category' => 'playoffs',
          'icon' => '🔥',
          'date' => semifinals_date.to_s,
          'formatted_date' => semifinals_date.strftime('%B %d, %Y'),
          'rule_ref' => '/rules/#6-playoff-structure',
          'description' => 'Division leaders take the field against Wild Card winners for a berth in the AFFL Super Bowl.'
        },
        {
          'id' => 'playoffs_championship',
          'title' => 'AFFL Super Bowl & Toilet Bowl Final (Week 17)',
          'tag' => 'Championship',
          'category' => 'playoffs',
          'icon' => '🏆',
          'date' => superbowl_date.to_s,
          'formatted_date' => superbowl_date.strftime('%B %d, %Y'),
          'rule_ref' => '/rules/#6-playoff-structure',
          'description' => 'Championship game crowns the AFFL Champion. Toilet Bowl concludes and determines next year\'s #1 pick.'
        },
        {
          'id' => 'pro_bowl_offseason',
          'title' => 'Off-Season Governance & Trading Window Opens',
          'tag' => 'Governance',
          'category' => 'governance',
          'icon' => '🗳️',
          'date' => pro_bowl_date.to_s,
          'formatted_date' => pro_bowl_date.strftime('%B %d, %Y'),
          'rule_ref' => '/rules/#7-league-rule-changes--governance',
          'description' => 'End of NFL Pro Bowl opens the window for rule change proposals, voting, and off-season trading.'
        }
      ]

      # Check for custom events in _data/custom_events.yml
      custom_file = File.join(site.source, '_data', 'custom_events.yml')
      if File.exist?(custom_file)
        begin
          custom_events = YAML.load_file(custom_file)
          if custom_events.is_a?(Array)
            default_events.concat(custom_events)
          end
        rescue StandardError => e
          warnings << "Error loading custom_events.yml: #{e.message}"
        end
      end

      # Sort events chronologically
      today = Date.today
      default_events.sort_by! { |e| Date.parse(e['date'].to_s) rescue Date.new(9999, 1, 1) }

      next_event = nil
      default_events.each do |event|
        ev_date = begin
          Date.parse(event['date'].to_s)
        rescue StandardError
          today
        end
        diff_days = (ev_date - today).to_i
        event['days_away'] = diff_days

        if diff_days < 0
          event['status'] = 'past'
          event['status_label'] = 'Completed'
        elsif diff_days == 0
          event['status'] = 'today'
          event['status_label'] = 'Happening Today'
          next_event ||= event
        else
          event['status'] = 'upcoming'
          event['status_label'] = diff_days == 1 ? 'Tomorrow' : "In #{diff_days} days"
          next_event ||= event
        end
      end

      # In case all events have passed, fallback to last
      next_event ||= default_events.last

      # Log warnings to Jekyll console and store in site.data
      site.data['date_warning'] = {
        'has_warning' => !warnings.empty?,
        'messages' => warnings
      }

      if !warnings.empty?
        warnings.each do |w|
          Jekyll.logger.warn "⚠️ [AFFL Calendar Warning]:", w
        end
      end

      site.data['league_calendar'] = default_events
      site.data['next_event'] = next_event
    end
  end
end

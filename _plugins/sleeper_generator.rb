require 'json'
require 'fileutils'

module Jekyll
  class SleeperMultiYearGenerator < Generator
    safe true
    priority :high

    def generate(site)
      calculate_league_state(site)

      seasons_dir = File.join(site.source, '_data', 'seasons')
      return unless Dir.exist?(seasons_dir)

      seasons = []
      teams_by_user = {}

      Dir.glob(File.join(seasons_dir, '*.json')).each do |file|
        begin
          season_data = JSON.parse(File.read(file))
          
          is_complete = season_data['status'] == 'complete'
          has_games = season_data['standings'] && season_data['standings'].any? { |s| (s['wins'].to_i + s['losses'].to_i) > 0 }

          # Identify winners
          if is_complete && season_data['standings'] && !season_data['standings'].empty?
            season_data['champion'] = season_data['standings'].first
            season_data['toilet_bowl_winner'] = season_data['standings'].find { |s| s['is_toilet_bowl_winner'] || s['rank'] == 7 } || season_data['standings'].last
            
            # Podiums
            season_data['podium'] = {
              'first' => season_data['standings'][0],
              'second' => season_data['standings'][1],
              'third' => season_data['standings'][2]
            }
          end
          
          # Calculate Season Awards & Notable Records (High Scores, Matchup Thrillers)
          if has_games && season_data['matchups'] && !season_data['matchups'].empty?
            all_season_matchups = []
            head_to_head_games = []

            season_data['matchups'].each do |week, games|
              by_matchup = {}
              games.each do |game|
                owner = season_data['standings'].find { |s| s['user_id'] == game['user_id'] }
                m_info = game.merge(
                  'week' => week.to_i,
                  'username' => owner ? owner['username'] : 'Unknown',
                  'team_name' => owner ? owner['team_name'] : 'Unknown Team',
                  'avatar' => owner ? owner['avatar'] : nil
                )
                all_season_matchups << m_info

                if game['matchup_id']
                  by_matchup[game['matchup_id']] ||= []
                  by_matchup[game['matchup_id']] << m_info
                end
              end

              by_matchup.each do |mid, pair|
                if pair.size == 2
                  t1, t2 = pair[0], pair[1]
                  p1, p2 = t1['points'].to_f, t2['points'].to_f
                  winner = p1 >= p2 ? t1 : t2
                  loser = p1 >= p2 ? t2 : t1
                  diff = (p1 - p2).abs.round(2)
                  total = (p1 + p2).round(2)

                  head_to_head_games << {
                    'week' => week.to_i,
                    'winner' => winner,
                    'loser' => loser,
                    'winner_points' => [p1, p2].max,
                    'loser_points' => [p1, p2].min,
                    'diff' => diff,
                    'total_points' => total
                  }
                end
              end
            end
            
            if !all_season_matchups.empty?
              high_score = all_season_matchups.max_by { |m| m['points'].to_f }
              low_score = all_season_matchups.select { |m| m['points'].to_f > 0 }.min_by { |m| m['points'].to_f }
              points_leader = season_data['standings'].max_by { |s| s['points_for'].to_f }
              pa_leader = season_data['standings'].max_by { |s| s['points_against'].to_f }
              best_rec = season_data['standings'].max_by { |s| [s['wins'].to_i, -s['losses'].to_i, s['points_for'].to_f] }
              top_matchup = head_to_head_games.max_by { |h| h['total_points'] }
              blowout = head_to_head_games.max_by { |h| h['diff'] }
              closest = head_to_head_games.min_by { |h| h['diff'] }

              season_data['awards'] = {
                'highest_game' => high_score,
                'lowest_game' => low_score,
                'regular_season_points_leader' => points_leader
              }
              season_data['records'] = {
                'high_score' => high_score,
                'low_score' => low_score,
                'points_leader' => points_leader,
                'pa_leader' => pa_leader,
                'best_record' => best_rec,
                'top_matchup' => top_matchup,
                'blowout' => blowout,
                'closest' => closest,
                'top_game_scores' => all_season_matchups.sort_by { |m| -m['points'].to_f }.first(5),
                'highest_scoring_matchups' => head_to_head_games.sort_by { |h| -h['total_points'] }.first(3),
                'largest_blowouts' => head_to_head_games.sort_by { |h| -h['diff'] }.first(3),
                'closest_matchups' => head_to_head_games.sort_by { |h| h['diff'] }.first(3)
              }
            end
          end

          seasons << season_data

          # Aggregate team data for Career Profiles
          season_data['standings'].each_with_index do |team, index|
            user_id = team['user_id']
            next unless user_id

            teams_by_user[user_id] ||= {
              'user_id' => user_id,
              'username' => team['username'],
              'current_team_name' => team['team_name'],
              'current_avatar' => team['avatar'],
              'seasons' => [],
              'matchups' => []
            }

            if season_data['year'].to_i >= (teams_by_user[user_id]['latest_year'] || 0).to_i
              teams_by_user[user_id]['current_team_name'] = team['team_name']
              teams_by_user[user_id]['current_avatar'] = team['avatar']
              teams_by_user[user_id]['latest_year'] = season_data['year']
            end

            # Only add to career historical record if season is complete or has played games
            if is_complete || (team['wins'].to_i + team['losses'].to_i > 0)
              teams_by_user[user_id]['seasons'] << {
                'year' => season_data['year'],
                'team_name' => team['team_name'],
                'rank' => team['rank'] || (index + 1),
                'is_toilet_bowl_winner' => team['is_toilet_bowl_winner'] || false,
                'wins' => team['wins'],
                'losses' => team['losses'],
                'points_for' => team['points_for'],
                'points_against' => team['points_against']
              }
            end
          end

          if season_data['matchups']
            season_data['matchups'].each do |week, games|
              games.each do |game|
                user_id = game['user_id']
                next unless user_id && teams_by_user[user_id]
                
                teams_by_user[user_id]['matchups'] << {
                  'year' => season_data['year'],
                  'week' => week.to_i,
                  'points' => game['points'].to_f,
                  'matchup_id' => game['matchup_id']
                }
              end
            end
          end

        rescue => e
          Jekyll.logger.warn "Error reading season file #{file}:", e.message
        end
      end

      # Sort seasons by year descending
      seasons.sort_by! { |s| -s['year'].to_i }
      site.data['all_seasons'] = seasons

      latest_comp = seasons.find { |s| s['status'] == 'complete' || (s['standings'] && s['standings'].any? { |t| (t['wins'].to_i + t['losses'].to_i) > 0 }) }
      site.data['latest_completed_season'] = latest_comp ? latest_comp['year'] : (seasons.first ? seasons.first['year'] : 2025)
      site.data['reigning_season'] = latest_comp

      if (site.config['current_draft_id'].nil? || site.config['current_draft_id'].to_s.strip.empty?) && seasons.first && seasons.first['draft_id']
        site.config['current_draft_id'] = seasons.first['draft_id']
      end

      # Generate Team Pages and Calculate All-Time Stats
      teams_by_user.each do |user_id, data|
        wins = data['seasons'].sum { |s| s['wins'] }
        losses = data['seasons'].sum { |s| s['losses'] }
        points_for = data['seasons'].sum { |s| s['points_for'] }
        points_against = data['seasons'].sum { |s| s['points_against'] }
        championships = data['seasons'].count { |s| s['rank'] == 1 }
        toilet_bowls = data['seasons'].count { |s| s['is_toilet_bowl_winner'] || s['rank'] == 7 }
        
        max_score = data['matchups'].max_by { |m| m['points'] } || { 'points' => 0, 'week' => 0, 'year' => 0 }
        
        total_games = wins + losses
        win_pct = total_games > 0 ? (wins.to_f / total_games * 100).round(2) : 0
        avg_points = total_games > 0 ? (points_for / total_games).round(2) : 0
        best_finish = data['seasons'].map { |s| s['rank'] }.min

        data['stats'] = {
          'wins' => wins,
          'losses' => losses,
          'points_for' => points_for,
          'points_against' => points_against,
          'win_pct' => win_pct,
          'avg_points' => avg_points,
          'championships' => championships,
          'toilet_bowls' => toilet_bowls,
          'best_finish' => best_finish,
          'max_score' => max_score
        }
        
        data['seasons'].sort_by! { |s| -s['year'].to_i }
        site.pages << TeamProfilePage.new(site, site.source, "teams/#{user_id}", data)
      end

      site.data['all_teams'] = teams_by_user.values.sort_by { |t| -t['stats']['wins'] }
      calculate_league_records(site, teams_by_user)
    end

    private

    def calculate_league_records(site, teams_by_user)
      all_matchups = []
      teams_by_user.each do |user_id, team|
        team['matchups'].each do |m|
          all_matchups << m.merge(
            'username' => team['username'],
            'team_name' => team['current_team_name'],
            'avatar' => team['current_avatar'],
            'user_id' => user_id
          )
        end
      end

      all_team_seasons = []
      site.data['all_seasons'].each do |season|
        next unless season['status'] == 'complete' || (season['standings'] && season['standings'].any? { |t| (t['wins'].to_i + t['losses'].to_i) > 0 })
        season['standings'].each do |team|
          all_team_seasons << team.merge(
            'year' => season['year'],
            'points_for_f' => team['points_for'].to_f,
            'points_against_f' => team['points_against'].to_f,
            'wins_i' => team['wins'].to_i,
            'losses_i' => team['losses'].to_i
          )
        end
      end

      completed_seasons = site.data['all_seasons'].select do |s|
        s['status'] == 'complete' || (s['standings'] && s['standings'].any? { |t| (t['wins'].to_i + t['losses'].to_i) > 0 })
      end

      site.data['records'] = {
        'highest_scores' => all_matchups.sort_by { |m| -m['points'] }.first(10),
        'lowest_scores' => all_matchups.select { |m| m['points'] > 0 }.sort_by { |m| m['points'] }.first(10),
        'most_season_points' => all_team_seasons.sort_by { |ts| -ts['points_for_f'] }.first(10),
        'best_season_records' => all_team_seasons.sort_by { |ts| [-ts['wins_i'], ts['losses_i'], -ts['points_for_f']] }.first(10),
        'most_championships' => teams_by_user.values.select { |t| t['stats']['championships'] > 0 }.sort_by { |t| -t['stats']['championships'] },
        'most_toilet_bowls' => teams_by_user.values.select { |t| t['stats']['toilet_bowls'] > 0 }.sort_by { |t| -t['stats']['toilet_bowls'] },
        'most_wins' => teams_by_user.values.sort_by { |t| -t['stats']['wins'] }.first(10),
        'highest_avg_points' => teams_by_user.values.select { |t| t['seasons'].size > 1 }.sort_by { |t| -t['stats']['avg_points'] }.first(10),
        'completed_seasons' => completed_seasons
      }
    end

    def calculate_league_state(site)
      now = Time.now
      draft_date_str = site.config['draft_date']
      return site.config['league_state'] = 'offseason' unless draft_date_str
      draft_date = Time.parse(draft_date_str)
      
      state = if now < draft_date
                prep_start = draft_date - (21 * 24 * 60 * 60)
                now >= prep_start ? 'predraft' : 'offseason'
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
    end
  end

  class TeamProfilePage < Page
    def initialize(site, base, dir, team_data)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'
      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'team.html')
      self.data['title'] = "Team Profile: #{team_data['username']}"
      self.data['team_data'] = team_data
    end
  end
end

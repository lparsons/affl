#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'uri'
require 'yaml'
require 'fileutils'

class SleeperAPI
  BASE_URL = 'https://api.sleeper.app/v1'
  
  def initialize(league_id)
    @league_id = league_id
  end
  
  def get_league_info(id = @league_id)
    response = make_request("/league/#{id}")
    JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
  end
  
  def get_league_users(id = @league_id)
    response = make_request("/league/#{id}/users")
    JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
  end
  
  def get_rosters(id = @league_id)
    response = make_request("/league/#{id}/rosters")
    JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
  end

  def get_matchups(week, id = @league_id)
    response = make_request("/league/#{id}/matchups/#{week}")
    JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
  end

  def get_winners_bracket(id = @league_id)
    response = make_request("/league/#{id}/winners_bracket")
    JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
  end

  def get_losers_bracket(id = @league_id)
    response = make_request("/league/#{id}/losers_bracket")
    JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
  end
  
  def generate_standings(id = @league_id)
    rosters = get_rosters(id)
    users = get_league_users(id)
    
    return nil unless rosters && users
    
    user_lookup = users.each_with_object({}) do |user, hash|
      hash[user['user_id']] = user
    end

    # Create roster lookup for internal mapping
    roster_lookup = rosters.each_with_object({}) do |roster, hash|
      hash[roster['roster_id']] = roster['owner_id']
    end
    
    roster_map = {}
    rosters.each do |roster|
      user = user_lookup[roster['owner_id']]
      team_name = user&.dig('metadata', 'team_name') || user&.dig('display_name') || 'Unknown Team'
      
      roster_map[roster['roster_id']] = {
        'user_id' => roster['owner_id'],
        'roster_id' => roster['roster_id'],
        'username' => user ? user['display_name'] : 'Unknown',
        'team_name' => team_name,
        'avatar' => user ? user['avatar'] : nil,
        'wins' => (roster['settings']['wins'] || 0).to_i,
        'losses' => (roster['settings']['losses'] || 0).to_i,
        'ties' => (roster['settings']['ties'] || 0).to_i,
        'points_for' => (roster['settings']['fpts'] || 0).to_f + (roster['settings']['fpts_decimal'] || 0).to_f / 100.0,
        'points_against' => (roster['settings']['fpts_against'] || 0).to_f + (roster['settings']['fpts_against_decimal'] || 0).to_f / 100.0,
        'record' => "#{roster['settings']['wins'] || 0}-#{roster['settings']['losses'] || 0}"
      }
    end

    # Calculate regular season ranking
    reg_sorted = roster_map.values.sort_by { |team| [-team['wins'], -team['points_for']] }
    reg_sorted.each_with_index do |team, idx|
      roster_map[team['roster_id']]['regular_season_rank'] = idx + 1
    end

    wb = get_winners_bracket(id) || []
    lb = get_losers_bracket(id) || []

    ranks = {}
    tb_winner_roster_id = nil

    # Check if winners bracket has completed championship match
    champ_m = wb.find { |m| m['p'] == 1 && m['w'] && m['l'] } || (wb.last if wb.last && wb.last['w'] && wb.last['l'])
    if champ_m
      ranks[1] = champ_m['w']
      ranks[2] = champ_m['l']

      third_m = wb.find { |m| m['p'] == 3 && m['w'] && m['l'] }
      if third_m
        ranks[3] = third_m['w']
        ranks[4] = third_m['l']
      end

      fifth_m = wb.find { |m| m['p'] == 5 && m['w'] && m['l'] }
      if fifth_m
        ranks[5] = fifth_m['w']
        ranks[6] = fifth_m['l']
      end

      # Losers / Toilet Bowl bracket
      tb_1 = lb.find { |m| m['p'] == 1 && m['w'] && m['l'] }
      if tb_1
        ranks[7] = tb_1['w']
        ranks[8] = tb_1['l']
        tb_winner_roster_id = tb_1['w']
      end

      tb_3 = lb.find { |m| m['p'] == 3 && m['w'] && m['l'] }
      if tb_3
        ranks[9] = tb_3['w']
        ranks[10] = tb_3['l']
      end

      tb_5 = lb.find { |m| m['p'] == 5 && m['w'] && m['l'] }
      if tb_5
        ranks[11] = tb_5['w']
        ranks[12] = tb_5['l']
      end

      assigned_rosters = ranks.values
      unassigned = roster_map.keys.reject { |rid| assigned_rosters.include?(rid) }
      unassigned_sorted = unassigned.sort_by do |rid|
        r = roster_map[rid]
        [-r['wins'], -r['points_for']]
      end

      final_standings = []
      total_teams = roster_map.size
      (1..total_teams).each do |rank|
        rid = ranks[rank] || unassigned_sorted.shift
        if rid && roster_map[rid]
          team_info = roster_map[rid].dup
          team_info['rank'] = rank
          if rid == tb_winner_roster_id
            team_info['is_toilet_bowl_winner'] = true
          end
          final_standings << team_info
        end
      end

      return [final_standings, roster_lookup]
    end
    
    # Fallback to regular season order if playoffs have not concluded
    standings = reg_sorted.map.with_index do |team, idx|
      t = team.dup
      t['rank'] = idx + 1
      t
    end

    [standings, roster_lookup]
  end
  
  private
  
  def make_request(endpoint)
    uri = URI("#{BASE_URL}#{endpoint}")
    Net::HTTP.get_response(uri)
  rescue => e
    puts "Error making request to #{endpoint}: #{e.message}"
    nil
  end
end

def update_all_seasons
  config = YAML.load_file('_config.yml')
  current_id = config['current_league_id']
  
  api = SleeperAPI.new(current_id)
  
  seasons_data = []
  processed_ids = []
  
  current_ptr = current_id
  
  puts "🔍 Discovering seasons..."
  
  while current_ptr && current_ptr != "0" && !processed_ids.include?(current_ptr)
    info = api.get_league_info(current_ptr)
    break unless info
    
    year = info['season']
    puts "Found Season: #{year} (ID: #{current_ptr})"
    
    standings, roster_to_owner = api.generate_standings(current_ptr)
    
    # Fetch all matchups for this season
    puts "  Fetching matchups for #{year}..."
    matchups_by_week = {}
    (1..18).each do |week|
      matchups = api.get_matchups(week, current_ptr)
      break if matchups.nil? || matchups.empty?
      
      # Simplify matchups for storage
      matchups_by_week[week] = matchups.map do |m|
        {
          'roster_id' => m['roster_id'],
          'user_id' => roster_to_owner[m['roster_id']],
          'matchup_id' => m['matchup_id'],
          'points' => m['points']
        }
      end
    end

    season_entry = {
      'year' => year.to_i,
      'league_id' => current_ptr,
      'draft_id' => info['draft_id'],
      'name' => info['name'],
      'status' => info['status'],
      'standings' => standings,
      'matchups' => matchups_by_week
    }
    
    # Save individual season data
    FileUtils.mkdir_p('_data/seasons')
    File.write("_data/seasons/#{year}.json", JSON.pretty_generate(season_entry))
    puts "✅ Saved _data/seasons/#{year}.json"
    
    seasons_data << { 'year' => year.to_i, 'league_id' => current_ptr }
    processed_ids << current_ptr
    current_ptr = info['previous_league_id']
  end
  
  # Save index of seasons
  File.write("_data/seasons_index.json", JSON.pretty_generate(seasons_data))
  puts "✅ Saved _data/seasons_index.json"
end

if __FILE__ == $0
  update_all_seasons
end

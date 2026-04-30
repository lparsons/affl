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
  
  def generate_standings(id = @league_id)
    rosters = get_rosters(id)
    users = get_league_users(id)
    
    return nil unless rosters && users
    
    user_lookup = users.each_with_object({}) do |user, hash|
      hash[user['user_id']] = user
    end
    
    standings = rosters.map do |roster|
      user = user_lookup[roster['owner_id']]
      team_name = user&.dig('metadata', 'team_name') || user&.dig('display_name') || 'Unknown Team'
      
      {
        'user_id' => roster['owner_id'],
        'username' => user ? user['display_name'] : 'Unknown',
        'team_name' => team_name,
        'wins' => (roster['settings']['wins'] || 0).to_i,
        'losses' => (roster['settings']['losses'] || 0).to_i,
        'ties' => (roster['settings']['ties'] || 0).to_i,
        'points_for' => (roster['settings']['fpts'] || 0).to_f + (roster['settings']['fpts_decimal'] || 0).to_f / 100.0,
        'points_against' => (roster['settings']['fpts_against'] || 0).to_f + (roster['settings']['fpts_against_decimal'] || 0).to_f / 100.0,
        'record' => "#{roster['settings']['wins'] || 0}-#{roster['settings']['losses'] || 0}"
      }
    end
    
    standings.sort_by { |team| [-team['wins'], -team['points_for']] }
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
    
    standings = api.generate_standings(current_ptr)
    
    season_entry = {
      'year' => year.to_i,
      'league_id' => current_ptr,
      'name' => info['name'],
      'status' => info['status'],
      'standings' => standings
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

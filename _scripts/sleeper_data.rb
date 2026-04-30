#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'uri'

class SleeperAPI
  BASE_URL = 'https://api.sleeper.app/v1'
  
  def initialize(league_id)
    @league_id = league_id
  end
  
  # Get league information
  def get_league_info
    response = make_request("/league/#{@league_id}")
    JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
  end
  
  # Get league users
  def get_league_users
    response = make_request("/league/#{@league_id}/users")
    JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
  end
  
  # Get current rosters
  def get_rosters
    response = make_request("/league/#{@league_id}/rosters")
    JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
  end
  
  # Get matchups for a specific week
  def get_matchups(week)
    response = make_request("/league/#{@league_id}/matchups/#{week}")
    JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
  end
  
  # Get transactions for a specific week
  def get_transactions(week)
    response = make_request("/league/#{@league_id}/transactions/#{week}")
    JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
  end
  
  # Get all NFL players
  def get_players
    response = make_request("/players/nfl")
    JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
  end
  
  # Generate standings data
  def generate_standings
    rosters = get_rosters
    users = get_league_users
    
    return nil unless rosters && users
    
    # Create user lookup
    user_lookup = users.each_with_object({}) do |user, hash|
      hash[user['user_id']] = user
    end
    
    # Process rosters and create standings
    standings = rosters.map do |roster|
      user = user_lookup[roster['owner_id']]
      {
        user_id: roster['owner_id'],
        username: user ? user['display_name'] : 'Unknown',
        team_name: user ? user['metadata']['team_name'] : 'Unknown Team',
        wins: roster['settings']['wins'],
        losses: roster['settings']['losses'],
        ties: roster['settings']['ties'],
        points_for: roster['settings']['fpts'].to_f,
        points_against: roster['settings']['fpts_against'].to_f,
        record: "#{roster['settings']['wins']}-#{roster['settings']['losses']}"
      }
    end
    
    # Sort by wins (descending), then by points for (descending)
    standings.sort_by { |team| [-team[:wins], -team[:points_for]] }
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

# Example usage
if __FILE__ == $0
  # Read league ID from Jekyll config
  require 'yaml'
  config = YAML.load_file('_config.yml')
  league_id = config['sleeper_league_id']
  
  api = SleeperAPI.new(league_id)
  
  # Get league info
  puts "=== League Information ==="
  league_info = api.get_league_info
  if league_info
    puts "League Name: #{league_info['name']}"
    puts "Season: #{league_info['season']}"
    puts "Total Teams: #{league_info['total_rosters']}"
  end
  
  # Get standings
  puts "\n=== Current Standings ==="
  standings = api.generate_standings
  if standings
    standings.each_with_index do |team, index|
      puts "#{index + 1}. #{team[:team_name]} (#{team[:username]}) - #{team[:record]} - #{sprintf('%.2f', team[:points_for])} PF"
    end
  end
  
  # Get current week matchups
  puts "\n=== Current Week Matchups ==="
  current_week = 1 # You'd want to determine this dynamically
  matchups = api.get_matchups(current_week)
  if matchups
    matchups.each do |matchup|
      puts "Matchup ID: #{matchup['matchup_id']} - Points: #{matchup['points']}"
    end
  end
end

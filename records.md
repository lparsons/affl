---
layout: page
title: Record Book
permalink: /records/
---

<div class="dashboard-container">
  <div class="dashboard-header">
    <div>
      <h1 style="margin: 0;">AFFL Record Book</h1>
      <p style="margin: 5px 0 0; opacity: 0.8;">The All-Time Greats & Historic Milestones of the Art of Fantasy Football</p>
    </div>
  </div>

  <div class="dashboard-grid">
    <!-- Hall of Champions Spotlight -->
    <div class="dashboard-card" style="grid-column: 1 / -1;">
      <h2>🏆 Hall of Champions</h2>
      <div style="display: flex; flex-wrap: wrap; gap: 25px; justify-content: space-around; padding: 15px 0;">
        {% for team in site.data.records.most_championships %}
          <div style="text-align: center; background: rgba(255,215,0,0.05); padding: 20px 25px; border-radius: 16px; border: 1px solid rgba(255,215,0,0.25); min-width: 160px;">
            <div style="position: relative; display: inline-block;">
              {% if team.current_avatar %}
                <img src="https://sleepercdn.com/avatars/thumbs/{{ team.current_avatar }}" style="width: 80px; height: 80px; border-radius: 50%; border: 4px solid #ffd700; box-shadow: 0 4px 15px rgba(255,215,0,0.3);">
              {% else %}
                <img src="https://sleepercdn.com/images/v2/icons/player_default.webp" style="width: 80px; height: 80px; border-radius: 50%;">
              {% endif %}
              <div style="position: absolute; bottom: -5px; right: -5px; background: #ffd700; color: #000; width: 32px; height: 32px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 900; font-size: 1.1em; border: 2px solid var(--bg-color);">
                {{ team.stats.championships }}
              </div>
            </div>
            <p style="margin: 15px 0 0; font-weight: 800; font-size: 1.1em;"><a href="{{ site.baseurl }}/teams/{{ team.user_id }}/">{{ team.username }}</a></p>
            <p style="margin: 0; font-size: 0.8em; opacity: 0.7;">{{ team.stats.championships }} {% if team.stats.championships == 1 %}Title{% else %}Titles{% endif %}</p>
          </div>
        {% endfor %}
      </div>
    </div>

    <!-- All-Time Single Game Scoring Titans -->
    <div class="dashboard-card" style="grid-column: 1 / -1;">
      <h2>🚀 All-Time Scoring Titans (Single-Week High Games)</h2>
      <p style="font-size: 0.85em; opacity: 0.7; margin-top: -10px; margin-bottom: 15px;">Highest single-game outputs across all AFFL regular season & playoff weeks</p>
      <div class="table-responsive">
        <table class="high-contrast-table">
          <thead>
            <tr>
              <th style="width: 80px; text-align: center;">Rank</th>
              <th style="width: 130px;">Score</th>
              <th>Team & Manager</th>
              <th style="width: 100px; text-align: center;">Season</th>
              <th style="width: 110px; text-align: center;">Week</th>
            </tr>
          </thead>
          <tbody>
            {% for game in site.data.records.highest_scores limit:10 %}
              <tr>
                <td style="font-weight: bold; white-space: nowrap; text-align: center;">
                  {% if forloop.index == 1 %}🥇 1{% elsif forloop.index == 2 %}🥈 2{% elsif forloop.index == 3 %}🥉 3{% else %}#{{ forloop.index }}{% endif %}
                </td>
                <td style="font-weight: 800; color: #4caf50; font-size: 1.1em; white-space: nowrap;">{{ game.points | round: 2 }}</td>
                <td>
                  <div style="font-weight: bold;"><a href="{{ site.baseurl }}/teams/{{ game.user_id }}/">{{ game.team_name }}</a></div>
                  <div style="opacity: 0.7; font-size: 0.85em;"><a href="{{ site.baseurl }}/teams/{{ game.user_id }}/">{{ game.username }}</a></div>
                </td>
                <td style="text-align: center;"><a href="{{ site.baseurl }}/seasons/#{{ game.year }}"><strong>{{ game.year }}</strong></a></td>
                <td style="font-size: 0.85em; opacity: 0.8; white-space: nowrap; text-align: center;">Week {{ game.week }}</td>
              </tr>
            {% endfor %}
          </tbody>
        </table>
      </div>
    </div>

    <!-- Consistency & Longevity -->
    <div class="dashboard-card">
      <h2>🔥 Career PPG Leaders</h2>
      <p style="font-size: 0.8em; opacity: 0.6; margin-top: -10px; margin-bottom: 15px;">Min. 2 seasons played</p>
      <div style="display: flex; flex-direction: column; gap: 10px;">
        {% for team in site.data.records.highest_avg_points limit:5 %}
          <div style="display: flex; align-items: center; justify-content: space-between; padding-bottom: 8px; border-bottom: 1px solid var(--border-color);">
            <div style="display: flex; align-items: center; gap: 10px;">
              <span style="font-weight: bold; opacity: 0.5;">#{{ forloop.index }}</span>
              <a href="{{ site.baseurl }}/teams/{{ team.user_id }}/" style="font-weight: bold;">{{ team.username }}</a>
            </div>
            <span style="font-weight: 800; color: var(--link-color);">{{ team.stats.avg_points | round: 2 }}</span>
          </div>
        {% endfor %}
      </div>
      
      <h2 style="margin-top: 25px;">📊 Most Career Wins</h2>
      <div style="display: flex; flex-direction: column; gap: 10px;">
        {% for team in site.data.records.most_wins limit:5 %}
          <div style="display: flex; align-items: center; justify-content: space-between; padding-bottom: 8px; border-bottom: 1px solid var(--border-color);">
            <div style="display: flex; align-items: center; gap: 10px;">
              <span style="font-weight: bold; opacity: 0.5;">#{{ forloop.index }}</span>
              <a href="{{ site.baseurl }}/teams/{{ team.user_id }}/" style="font-weight: bold;">{{ team.username }}</a>
            </div>
            <span style="font-weight: 800;">{{ team.stats.wins }} W <span style="opacity: 0.6; font-size: 0.85em;">({{ team.stats.win_pct }}%)</span></span>
          </div>
        {% endfor %}
      </div>

      {% if site.data.records.most_toilet_bowls and site.data.records.most_toilet_bowls.size > 0 %}
        <h2 style="margin-top: 25px;">🚽 Toilet Bowl Titles</h2>
        <div style="display: flex; flex-direction: column; gap: 10px;">
          {% for team in site.data.records.most_toilet_bowls limit:3 %}
            <div style="display: flex; align-items: center; justify-content: space-between; padding-bottom: 8px; border-bottom: 1px solid var(--border-color);">
              <div style="display: flex; align-items: center; gap: 10px;">
                <span style="font-size: 1.1em;">🚽</span>
                <a href="{{ site.baseurl }}/teams/{{ team.user_id }}/" style="font-weight: bold;">{{ team.username }}</a>
              </div>
              <span style="font-weight: 800; color: #ff9800;">{{ team.stats.toilet_bowls }} {% if team.stats.toilet_bowls == 1 %}Win{% else %}Wins{% endif %}</span>
            </div>
          {% endfor %}
        </div>
      {% endif %}
    </div>

    <!-- Best Single-Season Regular Records (Paired with Career Consistency) -->
    <div class="dashboard-card">
      <h2>⭐ Best Regular Season Records</h2>
      <p style="font-size: 0.8em; opacity: 0.6; margin-top: -10px; margin-bottom: 15px;">Most dominant regular season performances</p>
      <div style="display: flex; flex-direction: column; gap: 10px;">
        {% for season_stat in site.data.records.best_season_records limit:6 %}
          <div style="display: flex; align-items: center; justify-content: space-between; padding-bottom: 8px; border-bottom: 1px solid var(--border-color);">
            <div>
              <a href="{{ site.baseurl }}/teams/{{ season_stat.user_id }}/" style="font-weight: bold;">{{ season_stat.username }}</a>
              <span style="opacity: 0.6; font-size: 0.8em;">({{ season_stat.year }})</span>
            </div>
            <div style="text-align: right;">
              <span style="font-weight: 800; color: #4caf50;">{{ season_stat.record }}</span>
              <span style="opacity: 0.6; font-size: 0.8em; display: block;">{{ season_stat.points_for | round: 1 }} pts</span>
            </div>
          </div>
        {% endfor %}
      </div>
    </div>

    <!-- Single Season Points Titans -->
    <div class="dashboard-card" style="grid-column: 1 / -1;">
      <h2>👑 Single-Season Scoring Kings (Regular Season Points)</h2>
      <p style="font-size: 0.85em; opacity: 0.7; margin-top: -10px; margin-bottom: 15px;">Most total regular-season points scored in a single 14-game campaign</p>
      <div class="table-responsive">
        <table class="high-contrast-table">
          <thead>
            <tr>
              <th style="width: 80px; text-align: center;">Rank</th>
              <th style="width: 130px;">Points</th>
              <th>Team & Manager</th>
              <th style="width: 100px; text-align: center;">Season</th>
              <th style="width: 110px; text-align: center;">Record</th>
            </tr>
          </thead>
          <tbody>
            {% for season_stat in site.data.records.most_season_points limit:10 %}
              <tr>
                <td style="font-weight: bold; text-align: center;">
                  {% if forloop.index == 1 %}🥇 1{% elsif forloop.index == 2 %}🥈 2{% elsif forloop.index == 3 %}🥉 3{% else %}#{{ forloop.index }}{% endif %}
                </td>
                <td style="font-weight: 800; color: var(--link-color); font-size: 1.05em; white-space: nowrap;">{{ season_stat.points_for | round: 2 }}</td>
                <td>
                  <div style="font-weight: bold; white-space: nowrap;">{{ season_stat.team_name }}</div>
                  <div style="opacity: 0.7; font-size: 0.85em;"><a href="{{ site.baseurl }}/teams/{{ season_stat.user_id }}/">{{ season_stat.username }}</a></div>
                </td>
                <td style="text-align: center;"><a href="{{ site.baseurl }}/seasons/#{{ season_stat.year }}"><strong>{{ season_stat.year }}</strong></a></td>
                <td style="white-space: nowrap; text-align: center;">{{ season_stat.record }}</td>
              </tr>
            {% endfor %}
          </tbody>
        </table>
      </div>
    </div>

    <!-- Chronological Season Records Archive -->
    <div class="dashboard-card" style="grid-column: 1 / -1; margin-top: 10px;">
      <h2>📜 Annual Season Records & Honors Archive</h2>
      <p style="font-size: 0.85em; opacity: 0.7; margin-top: -10px; margin-bottom: 15px;">Comprehensive season-by-season champion, awards, and record holder timeline</p>
      <div class="table-responsive">
        <table class="high-contrast-table">
          <thead>
            <tr>
              <th style="min-width: 80px; width: 90px; text-align: center;">Season</th>
              <th style="width: 18%;">🥇 Champion</th>
              <th style="width: 18%;">🥈 Runner-Up</th>
              <th style="width: 18%;">🚽 Toilet Bowl (Pick #1)</th>
              <th style="width: 18%;">👑 Points King</th>
              <th style="width: 20%;">🚀 Season High Score</th>
            </tr>
          </thead>
          <tbody>
            {% for season in site.data.records.completed_seasons %}
              <tr>
                <td style="text-align: center;"><a href="{{ site.baseurl }}/seasons/#{{ season.year }}"><strong>{{ season.year }}</strong></a></td>
                <td>
                  {% if season.podium and season.podium.first %}
                    <div style="font-weight: bold; white-space: nowrap;"><a href="{{ site.baseurl }}/teams/{{ season.podium.first.user_id }}/">{{ season.podium.first.team_name }}</a></div>
                    <div style="opacity: 0.7; font-size: 0.85em;">{{ season.podium.first.username }}</div>
                  {% elsif season.champion %}
                    <div style="font-weight: bold; white-space: nowrap;"><a href="{{ site.baseurl }}/teams/{{ season.champion.user_id }}/">{{ season.champion.team_name }}</a></div>
                    <div style="opacity: 0.7; font-size: 0.85em;">{{ season.champion.username }}</div>
                  {% else %}
                    -
                  {% endif %}
                </td>
                <td>
                  {% if season.podium and season.podium.second %}
                    <div style="font-weight: bold; white-space: nowrap;"><a href="{{ site.baseurl }}/teams/{{ season.podium.second.user_id }}/">{{ season.podium.second.team_name }}</a></div>
                    <div style="opacity: 0.7; font-size: 0.85em;">{{ season.podium.second.username }}</div>
                  {% else %}
                    -
                  {% endif %}
                </td>
                <td>
                  {% if season.toilet_bowl_winner %}
                    <div style="font-weight: bold; white-space: nowrap;"><a href="{{ site.baseurl }}/teams/{{ season.toilet_bowl_winner.user_id }}/">{{ season.toilet_bowl_winner.team_name }}</a></div>
                    <div style="opacity: 0.7; font-size: 0.85em;">{{ season.toilet_bowl_winner.username }}</div>
                  {% else %}
                    -
                  {% endif %}
                </td>
                <td>
                  {% if season.awards and season.awards.regular_season_points_leader %}
                    <div style="font-weight: bold; color: var(--link-color); white-space: nowrap;">{{ season.awards.regular_season_points_leader.points_for | round: 2 }} pts</div>
                    <div style="opacity: 0.7; font-size: 0.85em;"><a href="{{ site.baseurl }}/teams/{{ season.awards.regular_season_points_leader.user_id }}/">{{ season.awards.regular_season_points_leader.username }}</a></div>
                  {% else %}
                    -
                  {% endif %}
                </td>
                <td>
                  {% if season.awards and season.awards.highest_game %}
                    <div style="font-weight: bold; color: #4caf50; white-space: nowrap;">{{ season.awards.highest_game.points | round: 2 }} pts</div>
                    <div style="opacity: 0.7; font-size: 0.85em;"><a href="{{ site.baseurl }}/teams/{{ season.awards.highest_game.user_id }}/">{{ season.awards.highest_game.username }} <span style="opacity: 0.7;">(Wk {{ season.awards.highest_game.week }})</span></a></div>
                  {% else %}
                    -
                  {% endif %}
                </td>
              </tr>
            {% endfor %}
          </tbody>
        </table>
      </div>
    </div>
  </div>
</div>


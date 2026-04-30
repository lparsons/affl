---
layout: page
title: Record Book
permalink: /records/
---

<div class="dashboard-container">
  <div class="dashboard-header">
    <div>
      <h1 style="margin: 0;">AFFL Record Book</h1>
      <p style="margin: 5px 0 0; opacity: 0.8;">The All-Time Greats of the Art of Fantasy Football</p>
    </div>
  </div>

  <div class="dashboard-grid">
    <!-- Hall of Champions Spotlight -->
    <div class="dashboard-card" style="grid-column: 1 / -1;">
      <h2>🏆 Hall of Champions</h2>
      <div style="display: flex; flex-wrap: wrap; gap: 30px; justify-content: space-around; padding: 10px 0;">
        {% for team in site.data.records.most_championships %}
          <div style="text-align: center; background: rgba(255,215,0,0.05); padding: 20px; border-radius: 16px; border: 1px solid rgba(255,215,0,0.2); min-width: 150px;">
            <div style="position: relative; display: inline-block;">
              {% if team.current_avatar %}
                <img src="https://sleepercdn.com/avatars/thumbs/{{ team.current_avatar }}" style="width: 80px; height: 80px; border-radius: 50%; border: 4px solid #ffd700; box-shadow: 0 4px 15px rgba(255,215,0,0.3);">
              {% else %}
                <img src="https://sleepercdn.com/images/v2/icons/player_default.webp" style="width: 80px; height: 80px; border-radius: 50%;">
              {% endif %}
              <div style="position: absolute; bottom: -5px; right: -5px; background: #ffd700; color: #000; width: 30px; height: 30px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 800; border: 2px solid var(--bg-color);">
                {{ team.stats.championships }}
              </div>
            </div>
            <p style="margin: 15px 0 0; font-weight: 800; font-size: 1.1em;"><a href="{{ site.baseurl }}/teams/{{ team.user_id }}/">{{ team.username }}</a></p>
          </div>
        {% endfor %}
      </div>
    </div>

    <!-- Scoring Titans -->
    <div class="dashboard-card" style="grid-column: span 2;">
      <h2>🚀 All-Time Scoring Titans (High Games)</h2>
      <table class="high-contrast-table">
        <thead>
          <tr>
            <th>Rank</th>
            <th>Score</th>
            <th>Manager</th>
            <th>Season</th>
            <th>Result</th>
          </tr>
        </thead>
        <tbody>
          {% for game in site.data.records.highest_scores limit:10 %}
            <tr>
              <td>{{ forloop.index }}</td>
              <td style="font-weight: 800; color: #4caf50; font-size: 1.1em;">{{ game.points | round: 2 }}</td>
              <td><a href="{{ site.baseurl }}/teams/{{ game.user_id }}/">{{ game.username }}</a></td>
              <td><a href="{{ site.baseurl }}/seasons/#{{ game.year }}">{{ game.year }}</a></td>
              <td style="font-size: 0.85em; opacity: 0.8;">Week {{ game.week }}</td>
            </tr>
          {% endfor %}
        </tbody>
      </table>
    </div>

    <!-- Consistency Card -->
    <div class="dashboard-card">
      <h2>🔥 Points Per Game Leaders</h2>
      <p style="font-size: 0.8em; opacity: 0.6; margin-top: -10px; margin-bottom: 15px;">Min. 2 seasons played</p>
      <div style="display: flex; flex-direction: column; gap: 12px;">
        {% for team in site.data.records.highest_avg_points limit:5 %}
          <div style="display: flex; align-items: center; justify-content: space-between; padding-bottom: 8px; border-bottom: 1px solid rgba(255,255,255,0.05);">
            <div style="display: flex; align-items: center; gap: 10px;">
              <span style="font-weight: bold; opacity: 0.5;">#{{ forloop.index }}</span>
              <a href="{{ site.baseurl }}/teams/{{ team.user_id }}/" style="font-weight: bold;">{{ team.username }}</a>
            </div>
            <span style="font-weight: 800; color: var(--link-color);">{{ team.stats.avg_points | round: 2 }}</span>
          </div>
        {% endfor %}
      </div>
      
      <h2 style="margin-top: 30px;">📊 Most Career Wins</h2>
      <div style="display: flex; flex-direction: column; gap: 12px;">
        {% for team in site.data.records.most_wins limit:5 %}
          <div style="display: flex; align-items: center; justify-content: space-between; padding-bottom: 8px; border-bottom: 1px solid rgba(255,255,255,0.05);">
            <div style="display: flex; align-items: center; gap: 10px;">
              <span style="font-weight: bold; opacity: 0.5;">#{{ forloop.index }}</span>
              <a href="{{ site.baseurl }}/teams/{{ team.user_id }}/" style="font-weight: bold;">{{ team.username }}</a>
            </div>
            <span style="font-weight: 800;">{{ team.stats.wins }}</span>
          </div>
        {% endfor %}
      </div>
    </div>
  </div>
</div>

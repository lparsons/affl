---
layout: page
title: Seasons Dashboard
permalink: /seasons/
---

<div class="dashboard-container">
  <div class="dashboard-header" style="justify-content: space-between; align-items: flex-start;">
    <div>
      <h1 style="margin: 0;" id="seasons-title">Season Dashboard</h1>
      <p style="margin: 5px 0 0; opacity: 0.8;" id="selected-season-label">Historical League Records</p>
    </div>
    <div style="display: flex; align-items: center; gap: 15px; background: var(--card-bg); padding: 10px 15px; border-radius: 12px; border: 1px solid var(--border-color);">
      <label for="season-selector" style="font-weight: bold; font-size: 0.9em; opacity: 0.7;">Select Year:</label>
      <select id="season-selector" style="padding: 8px 15px; border-radius: 8px; background: var(--header-bg); color: var(--text-color); border: 1px solid var(--border-color); font-weight: bold; cursor: pointer;">
        {% for season in site.data.all_seasons %}
          <option value="{{ season.year }}">{{ season.year }}{% if season.year == site.current_season %} (Current){% endif %}</option>
        {% endfor %}
      </select>
    </div>
  </div>

  <!-- Season Awards & Podium -->
  <div id="season-highlights" class="dashboard-grid">
    <!-- Will be injected by JS -->
  </div>

  <!-- Standings Table -->
  <div id="standings-content">
    <!-- Standings Table will be injected here by JS -->
  </div>
</div>

<script>
  const seasonSelector = document.getElementById('season-selector');
  const title = document.getElementById('seasons-title');
  const label = document.getElementById('selected-season-label');
  const highlightsContainer = document.getElementById('season-highlights');
  
  const seasonsData = {
    {% for season in site.data.all_seasons %}
      "{{ season.year }}": {
        "year": "{{ season.year }}",
        "name": "{{ season.name }}",
        "awards": {{ season.awards | jsonify }},
        "podium": {{ season.podium | jsonify }},
        "standings": [
          {% for team in season.standings %}
            {
              "rank": {{ forloop.index }},
              "team_name": {{ team.team_name | jsonify }},
              "username": "{{ team.username }}",
              "user_id": "{{ team.user_id }}",
              "record": "{{ team.record }}",
              "points_for": "{{ team.points_for | round: 2 }}",
              "points_against": "{{ team.points_against | round: 2 }}",
              "avatar": "{{ team.avatar }}"
            }{% unless forloop.last %},{% endunless %}
          {% endfor %}
        ]
      }{% unless forloop.last %},{% endunless %}
    {% endfor %}
  };

  function updateSeasonsDashboard(year) {
    const season = seasonsData[year];
    if (!season) return;

    title.textContent = `${year} Season Dashboard`;
    label.textContent = season.name;
    seasonSelector.value = year;

    // Build Highlights HTML
    let highlightsHtml = '';
    
    // Podium Card
    if (season.podium) {
      highlightsHtml += `
        <div class="dashboard-card" style="grid-column: span 2;">
          <h2>🏆 Final Podium</h2>
          <div style="display: flex; justify-content: space-around; align-items: flex-end; padding: 10px 0; gap: 20px;">
            <div style="text-align: center; flex: 1; order: 2;">
              <p style="font-size: 2em; margin: 0;">🥇</p>
              <img src="${season.podium.first.avatar ? 'https://sleepercdn.com/avatars/thumbs/' + season.podium.first.avatar : 'https://sleepercdn.com/images/v2/icons/player_default.webp'}" style="width: 70px; height: 70px; border-radius: 50%; border: 3px solid #ffd700;">
              <p style="margin: 5px 0 0; font-weight: 800;"><a href="{{ site.baseurl }}/teams/${season.podium.first.user_id}/">${season.podium.first.team_name}</a></p>
            </div>
            <div style="text-align: center; flex: 1; order: 1; opacity: 0.9;">
              <p style="font-size: 1.5em; margin: 0;">🥈</p>
              <img src="${season.podium.second.avatar ? 'https://sleepercdn.com/avatars/thumbs/' + season.podium.second.avatar : 'https://sleepercdn.com/images/v2/icons/player_default.webp'}" style="width: 55px; height: 55px; border-radius: 50%; border: 2px solid #c0c0c0;">
              <p style="margin: 5px 0 0; font-weight: bold; font-size: 0.9em;"><a href="{{ site.baseurl }}/teams/${season.podium.second.user_id}/">${season.podium.second.team_name}</a></p>
            </div>
            <div style="text-align: center; flex: 1; order: 3; opacity: 0.8;">
              <p style="font-size: 1.3em; margin: 0;">🥉</p>
              <img src="${season.podium.third.avatar ? 'https://sleepercdn.com/avatars/thumbs/' + season.podium.third.avatar : 'https://sleepercdn.com/images/v2/icons/player_default.webp'}" style="width: 50px; height: 50px; border-radius: 50%; border: 2px solid #cd7f32;">
              <p style="margin: 5px 0 0; font-weight: bold; font-size: 0.8em;"><a href="{{ site.baseurl }}/teams/${season.podium.third.user_id}/">${season.podium.third.team_name}</a></p>
            </div>
          </div>
        </div>
      `;
    }

    // Awards Card
    if (season.awards) {
      highlightsHtml += `
        <div class="dashboard-card">
          <h2>🌟 Season Honors</h2>
          <div style="display: flex; flex-direction: column; gap: 15px;">
            <div>
              <p style="margin: 0; font-size: 0.8em; opacity: 0.6; text-transform: uppercase; font-weight: 800;">High Score of Year</p>
              <p style="margin: 0; font-weight: bold; color: #4caf50;">${parseFloat(season.awards.highest_game.points).toFixed(2)} pts</p>
              <p style="margin: 0; font-size: 0.9em;"><a href="{{ site.baseurl }}/teams/${season.awards.highest_game.user_id}/">${season.awards.highest_game.team_name}</a> (Week ${season.awards.highest_game.week})</p>
            </div>
            <div style="border-top: 1px solid var(--border-color); padding-top: 10px;">
              <p style="margin: 0; font-size: 0.8em; opacity: 0.6; text-transform: uppercase; font-weight: 800;">Regular Season Points King</p>
              <p style="margin: 0; font-weight: bold; color: var(--link-color);">${parseFloat(season.awards.regular_season_points_leader.points_for).toFixed(2)} pts</p>
              <p style="margin: 0; font-size: 0.9em;"><a href="{{ site.baseurl }}/teams/${season.awards.regular_season_points_leader.user_id}/">${season.awards.regular_season_points_leader.team_name}</a></p>
            </div>
          </div>
        </div>
      `;
    }

    highlightsContainer.innerHTML = highlightsHtml;

    // Build Standings HTML
    let standingsHtml = `
      <div class="dashboard-card" style="margin-top: 20px;">
        <h2>Full Standings</h2>
        <table class="high-contrast-table">
          <thead>
            <tr>
              <th>Rank</th>
              <th>Team</th>
              <th>Manager</th>
              <th>Record</th>
              <th>PF</th>
              <th>PA</th>
            </tr>
          </thead>
          <tbody>
    `;
    
    season.standings.forEach(team => {
      const avatarUrl = team.avatar ? `https://sleepercdn.com/avatars/thumbs/${team.avatar}` : `https://sleepercdn.com/images/v2/icons/player_default.webp`;
      standingsHtml += `
        <tr>
          <td>${team.rank}</td>
          <td style="display: flex; align-items: center; gap: 10px;">
            <img src="${avatarUrl}" width="30" height="30" style="border-radius: 50%;">
            <a href="{{ site.baseurl }}/teams/${team.user_id}/">${team.team_name}</a>
          </td>
          <td>${team.username}</td>
          <td>${team.record}</td>
          <td>${team.points_for}</td>
          <td>${team.points_against}</td>
        </tr>
      `;
    });
    
    standingsHtml += `</tbody></table></div>`;
    document.getElementById('standings-content').innerHTML = standingsHtml;
  }

  seasonSelector.addEventListener('change', (e) => {
    updateSeasonsDashboard(e.target.value);
    window.location.hash = e.target.value;
  });

  window.addEventListener('load', () => {
    const hashYear = window.location.hash.substring(1);
    const latestYear = Object.keys(seasonsData).sort().reverse()[0];
    updateSeasonsDashboard(seasonsData[hashYear] ? hashYear : latestYear);
  });
</script>

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
        "toilet_bowl_winner": {{ season.toilet_bowl_winner | jsonify }},
        "standings": [
          {% for team in season.standings %}
            {
              "rank": {{ team.rank | default: forloop.index }},
              "regular_season_rank": {{ team.regular_season_rank | default: forloop.index }},
              "is_toilet_bowl_winner": {{ team.is_toilet_bowl_winner | default: false }},
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
              <p style="margin: 0; font-size: 0.8em; opacity: 0.7;">Champion (${season.podium.first.record})</p>
            </div>
            <div style="text-align: center; flex: 1; order: 1; opacity: 0.9;">
              <p style="font-size: 1.5em; margin: 0;">🥈</p>
              <img src="${season.podium.second.avatar ? 'https://sleepercdn.com/avatars/thumbs/' + season.podium.second.avatar : 'https://sleepercdn.com/images/v2/icons/player_default.webp'}" style="width: 55px; height: 55px; border-radius: 50%; border: 2px solid #c0c0c0;">
              <p style="margin: 5px 0 0; font-weight: bold; font-size: 0.9em;"><a href="{{ site.baseurl }}/teams/${season.podium.second.user_id}/">${season.podium.second.team_name}</a></p>
              <p style="margin: 0; font-size: 0.8em; opacity: 0.7;">Runner-Up (${season.podium.second.record})</p>
            </div>
            <div style="text-align: center; flex: 1; order: 3; opacity: 0.8;">
              <p style="font-size: 1.3em; margin: 0;">🥉</p>
              <img src="${season.podium.third.avatar ? 'https://sleepercdn.com/avatars/thumbs/' + season.podium.third.avatar : 'https://sleepercdn.com/images/v2/icons/player_default.webp'}" style="width: 50px; height: 50px; border-radius: 50%; border: 2px solid #cd7f32;">
              <p style="margin: 5px 0 0; font-weight: bold; font-size: 0.8em;"><a href="{{ site.baseurl }}/teams/${season.podium.third.user_id}/">${season.podium.third.team_name}</a></p>
              <p style="margin: 0; font-size: 0.8em; opacity: 0.7;">3rd Place (${season.podium.third.record})</p>
            </div>
          </div>
        </div>
      `;
    }

    // Awards & Honors Card
    if (season.awards || season.toilet_bowl_winner) {
      highlightsHtml += `
        <div class="dashboard-card">
          <h2>🌟 Season Honors</h2>
          <div style="display: flex; flex-direction: column; gap: 12px;">
      `;

      if (season.toilet_bowl_winner) {
        highlightsHtml += `
            <div>
              <p style="margin: 0; font-size: 0.8em; opacity: 0.6; text-transform: uppercase; font-weight: 800;">🚽 Toilet Bowl Winner (Pick #1)</p>
              <p style="margin: 0; font-weight: bold; color: #ff9800;"><a href="{{ site.baseurl }}/teams/${season.toilet_bowl_winner.user_id}/">${season.toilet_bowl_winner.team_name}</a></p>
              <p style="margin: 0; font-size: 0.85em; opacity: 0.8;">${season.toilet_bowl_winner.username} (${season.toilet_bowl_winner.record})</p>
            </div>
        `;
      }

      if (season.awards && season.awards.highest_game) {
        highlightsHtml += `
            <div style="border-top: 1px solid var(--border-color); padding-top: 10px;">
              <p style="margin: 0; font-size: 0.8em; opacity: 0.6; text-transform: uppercase; font-weight: 800;">🚀 High Score of Year</p>
              <p style="margin: 0; font-weight: bold; color: #4caf50;">${parseFloat(season.awards.highest_game.points).toFixed(2)} pts</p>
              <p style="margin: 0; font-size: 0.85em;"><a href="{{ site.baseurl }}/teams/${season.awards.highest_game.user_id}/">${season.awards.highest_game.team_name}</a> (Week ${season.awards.highest_game.week})</p>
            </div>
        `;
      }

      if (season.awards && season.awards.regular_season_points_leader) {
        highlightsHtml += `
            <div style="border-top: 1px solid var(--border-color); padding-top: 10px;">
              <p style="margin: 0; font-size: 0.8em; opacity: 0.6; text-transform: uppercase; font-weight: 800;">👑 Regular Season Points King</p>
              <p style="margin: 0; font-weight: bold; color: var(--link-color);">${parseFloat(season.awards.regular_season_points_leader.points_for).toFixed(2)} pts</p>
              <p style="margin: 0; font-size: 0.85em;"><a href="{{ site.baseurl }}/teams/${season.awards.regular_season_points_leader.user_id}/">${season.awards.regular_season_points_leader.team_name}</a></p>
            </div>
        `;
      }

      highlightsHtml += `
          </div>
        </div>
      `;
    }

    highlightsContainer.innerHTML = highlightsHtml;

    // Build Standings HTML
    let standingsHtml = `
      <div class="dashboard-card" style="margin-top: 20px;">
        <h2>Full Final Standings</h2>
        <p style="font-size: 0.85em; opacity: 0.7; margin-top: -10px; margin-bottom: 15px;">Final ranks determined by Playoff & Toilet Bowl Brackets</p>
        <table class="high-contrast-table">
          <thead>
            <tr>
              <th>Final Rank</th>
              <th>Team</th>
              <th>Manager</th>
              <th>Reg. Record (Seed)</th>
              <th>PF</th>
              <th>PA</th>
            </tr>
          </thead>
          <tbody>
    `;
    
    season.standings.forEach(team => {
      const avatarUrl = team.avatar ? `https://sleepercdn.com/avatars/thumbs/${team.avatar}` : `https://sleepercdn.com/images/v2/icons/player_default.webp`;
      let rankBadge = `${team.rank}`;
      if (team.rank === 1) rankBadge = '🥇 1';
      else if (team.rank === 2) rankBadge = '🥈 2';
      else if (team.rank === 3) rankBadge = '🥉 3';
      else if (team.is_toilet_bowl_winner || team.rank === 7) rankBadge = '🚽 7';

      const seedLabel = team.regular_season_rank ? `(#${team.regular_season_rank})` : '';

      standingsHtml += `
        <tr>
          <td style="font-weight: bold;">${rankBadge}</td>
          <td style="display: flex; align-items: center; gap: 10px;">
            <img src="${avatarUrl}" width="30" height="30" style="border-radius: 50%;">
            <a href="{{ site.baseurl }}/teams/${team.user_id}/">${team.team_name}</a>
          </td>
          <td>${team.username}</td>
          <td>${team.record} <span style="opacity: 0.6; font-size: 0.85em;">${seedLabel}</span></td>
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

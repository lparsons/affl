---
layout: page
title: Standings
permalink: /standings/
---

<div class="dashboard-container">
  <div class="dashboard-header" style="justify-content: space-between;">
    <div>
      <h1 style="margin: 0;" id="standings-title">Standings</h1>
      <p style="margin: 5px 0 0; opacity: 0.8;" id="selected-season-label">Historical League Records</p>
    </div>
    <div style="display: flex; align-items: center; gap: 15px;">
      <label for="season-selector" style="font-weight: bold; font-size: 0.9em; opacity: 0.7;">View Season:</label>
      <select id="season-selector" style="padding: 8px 15px; border-radius: 8px; background: var(--header-bg); color: var(--text-color); border: 1px solid var(--border-color); font-weight: bold; cursor: pointer;">
        {% for season in site.data.all_seasons %}
          <option value="{{ season.year }}">{{ season.year }}{% if season.year == site.current_season %} (Current){% endif %}</option>
        {% endfor %}
      </select>
    </div>
  </div>

  <div id="standings-content">
    <!-- Standings Table will be injected here by JS -->
  </div>
</div>

<script>
  const seasonSelector = document.getElementById('season-selector');
  const title = document.getElementById('standings-title');
  const label = document.getElementById('selected-season-label');
  
  const seasonsData = {
    {% for season in site.data.all_seasons %}
      "{{ season.year }}": {
        "year": "{{ season.year }}",
        "name": "{{ season.name }}",
        "standings": [
          {% for team in season.standings %}
            {
              "rank": {{ forloop.index }},
              "team_name": {{ team.team_name | jsonify }},
              "username": "{{ team.username }}",
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

  function updateStandings(year) {
    const season = seasonsData[year];
    if (!season) return;

    title.textContent = `${year} Standings`;
    label.textContent = season.name;
    seasonSelector.value = year;

    let html = `
      <div class="dashboard-card">
        <table class="high-contrast-table">
          <thead>
            <tr>
              <th>Rank</th>
              <th>Team</th>
              <th>Manager</th>
              <th>Record</th>
              <th>Points For</th>
              <th>Points Against</th>
            </tr>
          </thead>
          <tbody>
    `;
    
    season.standings.forEach(team => {
      const avatarUrl = team.avatar ? `https://sleepercdn.com/avatars/thumbs/${team.avatar}` : `https://sleepercdn.com/images/v2/icons/player_default.webp`;
      html += `
        <tr>
          <td>${team.rank}</td>
          <td style="display: flex; align-items: center; gap: 10px;">
            <img src="${avatarUrl}" width="30" height="30" style="border-radius: 50%;">
            ${team.team_name}
          </td>
          <td>${team.username}</td>
          <td>${team.record}</td>
          <td>${team.points_for}</td>
          <td>${team.points_against}</td>
        </tr>
      `;
    });
    
    html += `</tbody></table></div>`;
    document.getElementById('standings-content').innerHTML = html;
  }

  seasonSelector.addEventListener('change', (e) => {
    updateStandings(e.target.value);
    // Update hash for deep linking
    window.location.hash = e.target.value;
  });

  // Initial Load: Check hash or default to latest
  window.addEventListener('load', () => {
    const hashYear = window.location.hash.substring(1);
    const latestYear = Object.keys(seasonsData).sort().reverse()[0];
    updateStandings(seasonsData[hashYear] ? hashYear : latestYear);
  });
</script>

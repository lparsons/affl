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
        "status": "{{ season.status }}",
        "is_current": {% if season.year == site.current_season %}true{% else %}false{% endif %},
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

  function computeClinchStatus(standings, totalWeeks = 14) {
    if (!standings || standings.length === 0) return {};
    
    // Check total games played by top team
    const gamesPlayed = Math.max(...standings.map(t => {
      const parts = (t.record || "0-0").split("-");
      return (parseInt(parts[0]) || 0) + (parseInt(parts[1]) || 0);
    }));

    if (gamesPlayed === 0) return {};

    const remaining = Math.max(0, totalWeeks - gamesPlayed);

    const teamsWithBounds = standings.map((t, idx) => {
      const parts = (t.record || "0-0").split("-");
      const wins = parseInt(parts[0]) || 0;
      const pf = parseFloat(t.points_for) || 0;
      return {
        user_id: t.user_id,
        current_rank: idx + 1,
        wins: wins,
        max_wins: wins + remaining,
        pf: pf
      };
    });

    // Sorted by current wins desc, pf desc
    const sorted = [...teamsWithBounds].sort((a, b) => (b.wins - a.wins) || (b.pf - a.pf));

    const clinchMap = {};
    sorted.forEach((team, index) => {
      // 1. Bye clinch (Top 2 guaranteed): team's current wins > 3rd place team's max wins
      const thirdTeam = sorted[2];
      const isByeClinched = thirdTeam && (team.wins > thirdTeam.max_wins);

      // 2. Playoff clinch (Top 6 guaranteed): team's current wins > 7th place team's max wins
      const seventhTeam = sorted[6];
      const isPlayoffClinched = seventhTeam && (team.wins > seventhTeam.max_wins);

      // 3. Toilet Bowl Bound (Eliminated from Top 6): team's max wins < 6th place team's current wins
      const sixthTeam = sorted[5];
      const isEliminated = sixthTeam && (team.max_wins < sixthTeam.wins);

      if (isByeClinched) {
        clinchMap[team.user_id] = { label: 'Clinched Bye', badgeClass: 'badge-clinch badge-bye', icon: '⭐ [BYE] Bye Clinched' };
      } else if (isPlayoffClinched) {
        clinchMap[team.user_id] = { label: 'Clinched Playoffs', badgeClass: 'badge-clinch badge-playoffs', icon: '🟢 [X] Playoff Clinched' };
      } else if (isEliminated) {
        clinchMap[team.user_id] = { label: 'Toilet Bowl Bound', badgeClass: 'badge-clinch badge-tb', icon: '🚽 [TB] Toilet Bowl Bound' };
      } else if (index < 6) {
        clinchMap[team.user_id] = { label: 'In Playoff Position', badgeClass: 'badge-clinch badge-bubble', icon: '🟡 In Contention' };
      } else {
        clinchMap[team.user_id] = { label: 'In the Hunt', badgeClass: 'badge-clinch badge-hunt', icon: 'In the Hunt' };
      }
    });

    return clinchMap;
  }

  function updateSeasonsDashboard(year) {
    const season = seasonsData[year];
    if (!season) return;

    const isComplete = season.status === 'complete';
    const hasGames = season.standings && season.standings.some(t => {
      const parts = (t.record || "0-0").split("-");
      return (parseInt(parts[0]) || 0) + (parseInt(parts[1]) || 0) > 0;
    });

    title.textContent = `${year} Season Dashboard`;
    label.textContent = isComplete ? `${season.name} • Final Results` : `${season.name} • Season in Progress`;
    seasonSelector.value = year;

    let highlightsHtml = '';
    
    if (isComplete) {
      // 🏆 Final Podium Card
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

      // 🌟 Awards & Honors Card
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
    } else {
      // ⏳ Active / Pre-Draft Season Highlights
      if (!hasGames) {
        highlightsHtml += `
          <div class="dashboard-card" style="grid-column: span 2;">
            <h2>⏳ Pre-Draft Season Phase</h2>
            <p style="margin-top: 5px; opacity: 0.85; line-height: 1.6;">
              The <strong>${season.year} season</strong> is currently in the pre-draft stage. 
              Draft day is scheduled for <strong>August 30, 2026 at 09:00 AM</strong>.
            </p>
            <div style="margin-top: 15px; display: flex; gap: 10px; flex-wrap: wrap;">
              <a href="{{ site.baseurl }}/rules/" class="btn">View Draft & Keeper Rules</a>
              <a href="{{ site.baseurl }}/schedule/" class="btn">Milestone Timeline</a>
            </div>
          </div>
          <div class="dashboard-card">
            <h2>ℹ️ Playoff Qualification</h2>
            <p style="font-size: 0.9em; opacity: 0.85; margin: 0; line-height: 1.6;">
              • <strong>Top 6 Teams:</strong> Advance to Championship Playoffs (Top 2 division leaders earn 1st-round byes).<br>
              • <strong>Bottom 6 Teams:</strong> Compete in Toilet Bowl for next year's <strong>#1 Overall Pick</strong>.
            </p>
          </div>
        `;
      } else {
        highlightsHtml += `
          <div class="dashboard-card" style="grid-column: span 2;">
            <h2>🏈 Active Regular Season & Playoff Race</h2>
            <p style="margin-top: 5px; opacity: 0.85; line-height: 1.6;">
              Regular season standings below update in real time every Tuesday morning. Top 6 seeds punch tickets to the AFFL Championship Tournament, while Seeds 7–12 enter the Toilet Bowl bracket.
            </p>
            <div style="display: flex; gap: 8px; flex-wrap: wrap; margin-top: 12px;">
              <span class="badge-clinch badge-bye">⭐ [BYE] 1st-Round Bye Clinched</span>
              <span class="badge-clinch badge-playoffs">🟢 [X] Playoff Clinched</span>
              <span class="badge-clinch badge-tb">🚽 [TB] Toilet Bowl Bound</span>
              <span class="badge-clinch badge-bubble">🟡 In Contention</span>
            </div>
          </div>
          <div class="dashboard-card">
            <h2>🏆 Postseason Stakes</h2>
            <p style="font-size: 0.9em; opacity: 0.85; margin: 0; line-height: 1.6;">
              • <strong>Weeks 1–14:</strong> 14-game Regular Season.<br>
              • <strong>Weeks 15–17:</strong> 3-round Championship & Toilet Bowl Brackets.<br>
              • Final podium places & Toilet Bowl winner lock upon conclusion of Week 17.
            </p>
          </div>
        `;
      }
    }

    highlightsContainer.innerHTML = highlightsHtml;

    // Build Standings HTML
    const clinchMap = isComplete ? {} : computeClinchStatus(season.standings);

    let standingsHtml = `
      <div class="dashboard-card" style="margin-top: 20px;">
        <h2>${isComplete ? 'Full Final Standings' : 'Current Season Standings & Playoff Picture'}</h2>
        <p style="font-size: 0.85em; opacity: 0.7; margin-top: -10px; margin-bottom: 15px;">
          ${isComplete ? 'Final ranks determined by Playoff & Toilet Bowl Brackets' : 'Top 6 advance to Championship Playoffs; Seeds 7–12 enter Toilet Bowl for #1 pick'}
        </p>
        <table class="high-contrast-table">
          <thead>
            <tr>
              <th>${isComplete ? 'Final Rank' : 'Seed'}</th>
              <th>Team</th>
              <th>Manager</th>
              <th>${isComplete ? 'Reg. Record (Seed)' : 'Record'}</th>
              ${!isComplete && hasGames ? '<th>Clinch Status</th>' : ''}
              <th>PF</th>
              <th>PA</th>
            </tr>
          </thead>
          <tbody>
    `;
    
    season.standings.forEach((team, index) => {
      const avatarUrl = team.avatar ? `https://sleepercdn.com/avatars/thumbs/${team.avatar}` : `https://sleepercdn.com/images/v2/icons/player_default.webp`;
      
      let rankBadge = `${team.rank}`;
      if (isComplete) {
        if (team.rank === 1) rankBadge = '🥇 1';
        else if (team.rank === 2) rankBadge = '🥈 2';
        else if (team.rank === 3) rankBadge = '🥉 3';
        else if (team.is_toilet_bowl_winner || team.rank === 7) rankBadge = '🚽 7';
      } else {
        rankBadge = `#${index + 1}`;
      }

      const seedLabel = isComplete && team.regular_season_rank ? `(#${team.regular_season_rank})` : '';
      const clinch = clinchMap[team.user_id];

      // Add Playoff Cutoff Line divider after 6th place when season is active
      if (!isComplete && index === 6) {
        standingsHtml += `
          <tr class="playoff-cutline-row">
            <td colspan="${!isComplete && hasGames ? 7 : 6}">
              ⬆️ Top 6 Championship Playoffs (Seeds 1 & 2 Bye) • ⬇️ Bottom 6 Toilet Bowl Bracket (#1 Pick)
            </td>
          </tr>
        `;
      }

      standingsHtml += `
        <tr>
          <td style="font-weight: bold;">${rankBadge}</td>
          <td style="display: flex; align-items: center; gap: 10px;">
            <img src="${avatarUrl}" width="30" height="30" style="border-radius: 50%;">
            <a href="{{ site.baseurl }}/teams/${team.user_id}/">${team.team_name}</a>
          </td>
          <td>${team.username}</td>
          <td>${team.record} ${seedLabel ? `<span style="opacity: 0.6; font-size: 0.85em;">${seedLabel}</span>` : ''}</td>
          ${!isComplete && hasGames ? `<td>${clinch ? `<span class="${clinch.badgeClass}">${clinch.icon}</span>` : '-'}</td>` : ''}
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


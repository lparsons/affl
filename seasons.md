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
          {% assign has_played_games = false %}
          {% for s in season.standings %}
            {% assign total_g = s.wins | plus: s.losses %}
            {% if total_g > 0 %}{% assign has_played_games = true %}{% endif %}
          {% endfor %}
          <option value="{{ season.year }}">
            {{ season.year }}{% if season.year == site.current_season and has_played_games == false %} (Upcoming / Pre-Draft){% elsif season.year == site.data.latest_completed_season %} (Latest Final){% endif %}
          </option>
        {% endfor %}
      </select>
    </div>
  </div>

  <!-- Season Awards & Podium / Phase Highlights -->
  <div id="season-highlights" class="dashboard-grid">
    <!-- Injected by JS -->
  </div>

  <!-- Standings / Divisions Content -->
  <div id="standings-content">
    <!-- Injected by JS -->
  </div>

  <!-- All-Time Seasons & Champions Archive Table -->
  <div class="dashboard-card" style="margin-top: 35px; grid-column: 1 / -1;">
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; flex-wrap: wrap; gap: 10px;">
      <div>
        <h2 style="margin: 0;">📜 All-Time Season Records & Honors Archive</h2>
        <p style="margin: 4px 0 0; font-size: 0.85em; opacity: 0.7;">Complete chronological honor roll and milestones across all AFFL seasons (2019–2025)</p>
      </div>
      <a href="{{ site.baseurl }}/records/" class="btn" style="padding: 6px 14px; font-size: 0.85em;">All-Time Record Book ↗</a>
    </div>
    <table class="high-contrast-table">
      <thead>
        <tr>
          <th>Season</th>
          <th>🥇 Champion</th>
          <th>🥈 Runner-Up</th>
          <th>🚽 Toilet Bowl (Pick #1)</th>
          <th>👑 Points King</th>
          <th>🚀 Season High Score</th>
        </tr>
      </thead>
      <tbody>
        {% for s in site.data.records.completed_seasons %}
          <tr>
            <td>
              <button onclick="updateSeasonsDashboard('{{ s.year }}'); window.location.hash='{{ s.year }}'; window.scrollTo({top: 0, behavior: 'smooth'});" style="background: rgba(42, 122, 226, 0.15); color: var(--link-color); border: 1px solid var(--border-color); font-weight: bold; border-radius: 6px; padding: 4px 10px; cursor: pointer;" title="View {{ s.year }} Season Dashboard">
                {{ s.year }} ↗
              </button>
            </td>
            <td>
              {% if s.podium and s.podium.first %}
                <a href="{{ site.baseurl }}/teams/{{ s.podium.first.user_id }}/" style="font-weight: bold;">{{ s.podium.first.team_name }}</a> <span style="opacity: 0.7; font-size: 0.85em;">({{ s.podium.first.username }})</span>
              {% elsif s.champion %}
                <a href="{{ site.baseurl }}/teams/{{ s.champion.user_id }}/" style="font-weight: bold;">{{ s.champion.team_name }}</a> <span style="opacity: 0.7; font-size: 0.85em;">({{ s.champion.username }})</span>
              {% else %}
                -
              {% endif %}
            </td>
            <td>
              {% if s.podium and s.podium.second %}
                <a href="{{ site.baseurl }}/teams/{{ s.podium.second.user_id }}/">{{ s.podium.second.team_name }}</a> <span style="opacity: 0.7; font-size: 0.85em;">({{ s.podium.second.username }})</span>
              {% else %}
                -
              {% endif %}
            </td>
            <td>
              {% if s.toilet_bowl_winner %}
                <a href="{{ site.baseurl }}/teams/{{ s.toilet_bowl_winner.user_id }}/">{{ s.toilet_bowl_winner.team_name }}</a> <span style="opacity: 0.7; font-size: 0.85em;">({{ s.toilet_bowl_winner.username }})</span>
              {% else %}
                -
              {% endif %}
            </td>
            <td>
              {% if s.awards and s.awards.regular_season_points_leader %}
                <span style="font-weight: bold; color: var(--link-color);">{{ s.awards.regular_season_points_leader.points_for | round: 2 }} pts</span>
                <span style="opacity: 0.7; font-size: 0.85em;"><a href="{{ site.baseurl }}/teams/{{ s.awards.regular_season_points_leader.user_id }}/">({{ s.awards.regular_season_points_leader.username }})</a></span>
              {% else %}
                -
              {% endif %}
            </td>
            <td>
              {% if s.awards and s.awards.highest_game %}
                <span style="font-weight: bold; color: #4caf50;">{{ s.awards.highest_game.points | round: 2 }} pts</span>
                <span style="opacity: 0.7; font-size: 0.85em;"><a href="{{ site.baseurl }}/teams/{{ s.awards.highest_game.user_id }}/">({{ s.awards.highest_game.username }}, Wk {{ s.awards.highest_game.week }})</a></span>
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

<script>
  const seasonSelector = document.getElementById('season-selector');
  const title = document.getElementById('seasons-title');
  const label = document.getElementById('selected-season-label');
  const highlightsContainer = document.getElementById('season-highlights');
  const defaultSeasonYear = "{{ site.data.latest_completed_season | default: 2025 }}";
  
  const seasonsData = {
    {% for season in site.data.all_seasons %}
      "{{ season.year }}": {
        "year": "{{ season.year }}",
        "name": "{{ season.name }}",
        "status": "{{ season.status }}",
        "draft_id": "{{ season.draft_id }}",
        "is_current": {% if season.year == site.current_season %}true{% else %}false{% endif %},
        "awards": {{ season.awards | jsonify }},
        "records": {{ season.records | jsonify }},
        "podium": {{ season.podium | jsonify }},
        "toilet_bowl_winner": {{ season.toilet_bowl_winner | jsonify }},
        "divisions": {{ season.divisions | jsonify }},
        "standings": [
          {% for team in season.standings %}
            {
              "rank": {{ team.rank | default: forloop.index }},
              "regular_season_rank": {{ team.regular_season_rank | default: forloop.index }},
              "is_toilet_bowl_winner": {{ team.is_toilet_bowl_winner | default: false }},
              "team_name": {{ team.team_name | jsonify }},
              "username": "{{ team.username }}",
              "user_id": "{{ team.user_id }}",
              "division": {{ team.division | default: 1 }},
              "division_name": "{{ team.division_name | default: 'Yin' }}",
              "draft_slot": {{ team.draft_slot | jsonify }},
              "record": "{{ team.record }}",
              "wins": {{ team.wins | default: 0 }},
              "losses": {{ team.losses | default: 0 }},
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

    const sorted = [...teamsWithBounds].sort((a, b) => (b.wins - a.wins) || (b.pf - a.pf));

    const clinchMap = {};
    sorted.forEach((team, index) => {
      const thirdTeam = sorted[2];
      const isByeClinched = thirdTeam && (team.wins > thirdTeam.max_wins);

      const seventhTeam = sorted[6];
      const isPlayoffClinched = seventhTeam && (team.wins > seventhTeam.max_wins);

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
      return (parseInt(t.wins) || 0) + (parseInt(t.losses) || 0) > 0;
    });

    title.textContent = `${year} Season Dashboard`;
    label.textContent = isComplete ? `${season.name} • Final Results` : `${season.name} • ${hasGames ? 'Regular Season in Progress' : 'Pre-Draft & Rosters'}`;
    seasonSelector.value = year;

    let highlightsHtml = '';
    let contentHtml = '';
    
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

      // Standings Table for Completed Season
      contentHtml = `
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

        contentHtml += `
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
      
      contentHtml += `</tbody></table></div>`;
      contentHtml += renderSeasonRecords(season);

    } else if (!hasGames) {
      // ⏳ PRE-DRAFT / PRE-SEASON VIEW (NO EMPTY TABLE!)
      highlightsHtml += `
        <div class="dashboard-card" style="grid-column: span 2;">
          <h2>🏈 ${season.year} Season • Pre-Draft Setup</h2>
          <p style="margin-top: 5px; opacity: 0.85; line-height: 1.6;">
            The <strong>${season.year} season</strong> is configured with 12 managers across 2 divisions. 
            The slow snake draft commences on <strong>Sunday, August 30, 2026 at 09:00 AM EDT</strong>.
          </p>
          <div style="margin-top: 15px; display: flex; gap: 10px; flex-wrap: wrap;">
            <a href="https://sleeper.com/draft/nfl/${season.draft_id || '{{ site.current_draft_id }}'}?is_active=true" target="_blank" class="btn">🚀 Enter Sleeper Draft Room</a>
            <a href="{{ site.baseurl }}/rules/" class="btn" style="background: rgba(255,255,255,0.1); color: var(--text-color) !important;">Constitution & Rules</a>
            <a href="{{ site.baseurl }}/schedule/" class="btn" style="background: rgba(255,255,255,0.1); color: var(--text-color) !important;">Milestone Schedule</a>
          </div>
        </div>
        <div class="dashboard-card">
          <h2>📋 League Configuration</h2>
          <div style="font-size: 0.9em; opacity: 0.85; display: flex; flex-direction: column; gap: 8px;">
            <div><strong>Roster:</strong> 1 QB, 2 RB, 2 WR, 1 TE, 1 FLEX, 1 K, 1 DEF, 5 BN</div>
            <div><strong>Keepers:</strong> 1 Keeper per team (Forfeits Round 1 pick)</div>
            <div><strong>Playoffs:</strong> Weeks 15–17 (Top 6 advance, Top 2 bye)</div>
            <div><strong>Toilet Bowl:</strong> Winner gets next year's <strong>#1 Pick</strong></div>
          </div>
        </div>
      `;

      // Group teams by Division for Division View
      const yinTeams = season.standings.filter(t => t.division === 1);
      const yangTeams = season.standings.filter(t => t.division === 2);

      contentHtml = `
        <div style="margin-top: 25px;">
          <h2 style="margin-bottom: 5px;">☯️ Division Alignments</h2>
          <p style="font-size: 0.9em; opacity: 0.7; margin-bottom: 20px;">12 Franchises split across the Yin and Yang Divisions for the ${season.year} campaign</p>
          
          <div class="dashboard-grid" style="grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 20px;">
            <!-- Yin Division Card -->
            <div class="dashboard-card" style="border-top: 4px solid var(--link-color);">
              <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 15px;">
                <h3 style="margin: 0; font-size: 1.25em;">☯️ Yin Division</h3>
                <span class="category-tag">6 Teams</span>
              </div>
              <div style="display: flex; flex-direction: column; gap: 12px;">
                ${yinTeams.map(t => {
                  const avatarUrl = t.avatar ? `https://sleepercdn.com/avatars/thumbs/${t.avatar}` : `https://sleepercdn.com/images/v2/icons/player_default.webp`;
                  const draftBadge = t.draft_slot ? `<span class="badge-clinch badge-hunt" title="Draft Pick Slot">Pick #${t.draft_slot}</span>` : '';
                  return `
                    <div style="display: flex; align-items: center; justify-content: space-between; padding: 8px 10px; background: rgba(255,255,255,0.03); border-radius: 8px; border: 1px solid var(--border-color);">
                      <div style="display: flex; align-items: center; gap: 12px;">
                        <img src="${avatarUrl}" width="36" height="36" style="border-radius: 50%;">
                        <div>
                          <p style="margin: 0; font-weight: bold;"><a href="{{ site.baseurl }}/teams/${t.user_id}/">${t.team_name}</a></p>
                          <p style="margin: 0; font-size: 0.8em; opacity: 0.7;">${t.username}</p>
                        </div>
                      </div>
                      ${draftBadge}
                    </div>
                  `;
                }).join('')}
              </div>
            </div>

            <!-- Yang Division Card -->
            <div class="dashboard-card" style="border-top: 4px solid #ff9800;">
              <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 15px;">
                <h3 style="margin: 0; font-size: 1.25em;">☯️ Yang Division</h3>
                <span class="category-tag" style="background: rgba(255, 152, 0, 0.15); color: #ff9800;">6 Teams</span>
              </div>
              <div style="display: flex; flex-direction: column; gap: 12px;">
                ${yangTeams.map(t => {
                  const avatarUrl = t.avatar ? `https://sleepercdn.com/avatars/thumbs/${t.avatar}` : `https://sleepercdn.com/images/v2/icons/player_default.webp`;
                  const draftBadge = t.draft_slot ? `<span class="badge-clinch badge-hunt" title="Draft Pick Slot">Pick #${t.draft_slot}</span>` : '';
                  return `
                    <div style="display: flex; align-items: center; justify-content: space-between; padding: 8px 10px; background: rgba(255,255,255,0.03); border-radius: 8px; border: 1px solid var(--border-color);">
                      <div style="display: flex; align-items: center; gap: 12px;">
                        <img src="${avatarUrl}" width="36" height="36" style="border-radius: 50%;">
                        <div>
                          <p style="margin: 0; font-weight: bold;"><a href="{{ site.baseurl }}/teams/${t.user_id}/">${t.team_name}</a></p>
                          <p style="margin: 0; font-size: 0.8em; opacity: 0.7;">${t.username}</p>
                        </div>
                      </div>
                      ${draftBadge}
                    </div>
                  `;
                }).join('')}
              </div>
            </div>
          </div>

          <!-- Draft Order Board -->
          <div class="dashboard-card" style="margin-top: 25px;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
              <div>
                <h3 style="margin: 0; font-size: 1.2em;">🎯 ${season.year} Draft Order Board</h3>
                <p style="margin: 3px 0 0; font-size: 0.85em; opacity: 0.7;">14-Round Slow Snake Draft • August 30 @ 9:00 AM EDT</p>
              </div>
              <a href="https://sleeper.com/draft/nfl/${season.draft_id || '{{ site.current_draft_id }}'}?is_active=true" target="_blank" class="btn" style="padding: 6px 14px; font-size: 0.85em;">Draft Room ↗</a>
            </div>
            <table class="high-contrast-table">
              <thead>
                <tr>
                  <th style="width: 80px;">Slot</th>
                  <th>Team</th>
                  <th>Manager</th>
                  <th>Division</th>
                </tr>
              </thead>
              <tbody>
                ${[...season.standings].sort((a, b) => (a.draft_slot || 99) - (b.draft_slot || 99)).map(t => {
                  const avatarUrl = t.avatar ? `https://sleepercdn.com/avatars/thumbs/${t.avatar}` : `https://sleepercdn.com/images/v2/icons/player_default.webp`;
                  return `
                    <tr>
                      <td style="font-weight: 800; color: var(--link-color);">#${t.draft_slot || '-'}</td>
                      <td style="display: flex; align-items: center; gap: 10px;">
                        <img src="${avatarUrl}" width="28" height="28" style="border-radius: 50%;">
                        <a href="{{ site.baseurl }}/teams/${t.user_id}/">${t.team_name}</a>
                      </td>
                      <td>${t.username}</td>
                      <td><span class="category-tag">${t.division_name || 'Yin'}</span></td>
                    </tr>
                  `;
                }).join('')}
              </tbody>
            </table>
          </div>

          <!-- Note about live standings activation -->
          <div style="margin-top: 20px; padding: 15px 20px; background: rgba(42, 122, 226, 0.08); border: 1px dashed var(--link-color); border-radius: 10px; font-size: 0.88em; color: var(--text-color); opacity: 0.9;">
            ℹ️ <strong>Live Standings Notice:</strong> Win-loss standings, total points, weekly high scores, and mathematical playoff clinch trackers will automatically activate on this page once NFL Week 1 matchups kick off in September.
          </div>
        </div>
      `;

    } else {
      // 🏈 ACTIVE REGULAR SEASON IN PROGRESS (GAMES PLAYED)
      highlightsHtml += `
        <div class="dashboard-card" style="grid-column: span 2;">
          <h2>🏈 Active Regular Season & Playoff Race</h2>
          <p style="margin-top: 5px; opacity: 0.85; line-height: 1.6;">
            Standings below update live every Tuesday morning. Top 6 seeds punch tickets to the Championship Playoffs (Seeds 1 & 2 earn byes), while Seeds 7–12 compete in the Toilet Bowl bracket.
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

      const clinchMap = computeClinchStatus(season.standings);

      contentHtml = `
        <div class="dashboard-card" style="margin-top: 20px;">
          <h2>Current Season Standings & Playoff Picture</h2>
          <p style="font-size: 0.85em; opacity: 0.7; margin-top: -10px; margin-bottom: 15px;">
            Top 6 advance to Championship Playoffs; Seeds 7–12 enter Toilet Bowl for #1 draft pick
          </p>
          <table class="high-contrast-table">
            <thead>
              <tr>
                <th>Seed</th>
                <th>Team</th>
                <th>Manager</th>
                <th>Record</th>
                <th>Playoff Status</th>
                <th>PF</th>
                <th>PA</th>
              </tr>
            </thead>
            <tbody>
      `;
      
      season.standings.forEach((team, index) => {
        const avatarUrl = team.avatar ? `https://sleepercdn.com/avatars/thumbs/${team.avatar}` : `https://sleepercdn.com/images/v2/icons/player_default.webp`;
        const clinch = clinchMap[team.user_id];

        if (index === 6) {
          contentHtml += `
            <tr class="playoff-cutline-row">
              <td colspan="7">
                ⬆️ Top 6 Championship Playoffs (Seeds 1 & 2 Bye) • ⬇️ Bottom 6 Toilet Bowl Bracket (#1 Pick)
              </td>
            </tr>
          `;
        }

        contentHtml += `
          <tr>
            <td style="font-weight: bold;">#${index + 1}</td>
            <td style="display: flex; align-items: center; gap: 10px;">
              <img src="${avatarUrl}" width="30" height="30" style="border-radius: 50%;">
              <a href="{{ site.baseurl }}/teams/${team.user_id}/">${team.team_name}</a>
            </td>
            <td>${team.username}</td>
            <td>${team.record}</td>
            <td>${clinch ? `<span class="${clinch.badgeClass}">${clinch.icon}</span>` : '-'}</td>
            <td>${team.points_for}</td>
            <td>${team.points_against}</td>
          </tr>
        `;
      });
      
      contentHtml += `</tbody></table></div>`;
      contentHtml += renderSeasonRecords(season);
    }

    highlightsContainer.innerHTML = highlightsHtml;
    document.getElementById('standings-content').innerHTML = contentHtml;
  }

  function renderSeasonRecords(season) {
    if (!season.records) return '';
    const r = season.records;
    return `
      <div style="margin-top: 30px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; flex-wrap: wrap; gap: 10px;">
          <h2 style="margin: 0;">📊 ${season.year} Season Records & Superlatives</h2>
          <span class="category-tag">${season.year} Milestones</span>
        </div>

        <!-- Superlatives Summary Grid -->
        <div class="dashboard-grid" style="grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 15px; margin-bottom: 20px;">
          ${r.high_score ? `
            <div class="dashboard-card" style="padding: 15px; border-left: 4px solid #4caf50;">
              <p style="margin: 0; font-size: 0.75em; color: #4caf50; text-transform: uppercase; font-weight: 800;">🚀 Season High Score</p>
              <p style="margin: 4px 0 0; font-size: 1.25em; font-weight: 800; color: #4caf50;">${parseFloat(r.high_score.points).toFixed(2)} pts</p>
              <p style="margin: 2px 0 0; font-size: 0.85em;"><a href="{{ site.baseurl }}/teams/${r.high_score.user_id}/"><strong>${r.high_score.username}</strong></a> (${r.high_score.team_name}, Wk ${r.high_score.week})</p>
            </div>
          ` : ''}

          ${r.points_leader ? `
            <div class="dashboard-card" style="padding: 15px; border-left: 4px solid var(--link-color);">
              <p style="margin: 0; font-size: 0.75em; color: var(--link-color); text-transform: uppercase; font-weight: 800;">👑 Total Points Leader</p>
              <p style="margin: 4px 0 0; font-size: 1.25em; font-weight: 800; color: var(--link-color);">${parseFloat(r.points_leader.points_for).toFixed(2)} pts</p>
              <p style="margin: 2px 0 0; font-size: 0.85em;"><a href="{{ site.baseurl }}/teams/${r.points_leader.user_id}/"><strong>${r.points_leader.username}</strong></a> (${r.points_leader.team_name})</p>
            </div>
          ` : ''}

          ${r.best_record ? `
            <div class="dashboard-card" style="padding: 15px; border-left: 4px solid #ffd700;">
              <p style="margin: 0; font-size: 0.75em; color: #ffd700; text-transform: uppercase; font-weight: 800;">⭐ Best Regular Record</p>
              <p style="margin: 4px 0 0; font-size: 1.25em; font-weight: 800;">${r.best_record.record}</p>
              <p style="margin: 2px 0 0; font-size: 0.85em;"><a href="{{ site.baseurl }}/teams/${r.best_record.user_id}/"><strong>${r.best_record.username}</strong></a> (${r.best_record.team_name})</p>
            </div>
          ` : ''}

          ${r.pa_leader ? `
            <div class="dashboard-card" style="padding: 15px; border-left: 4px solid #f44336;">
              <p style="margin: 0; font-size: 0.75em; color: #f44336; text-transform: uppercase; font-weight: 800;">🛡️ Toughest Schedule (Most PA)</p>
              <p style="margin: 4px 0 0; font-size: 1.25em; font-weight: 800;">${parseFloat(r.pa_leader.points_against).toFixed(2)} pts</p>
              <p style="margin: 2px 0 0; font-size: 0.85em;"><a href="{{ site.baseurl }}/teams/${r.pa_leader.user_id}/"><strong>${r.pa_leader.username}</strong></a> (${r.pa_leader.team_name})</p>
            </div>
          ` : ''}
        </div>

        <div class="dashboard-grid" style="grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 20px;">
          <!-- Top Single-Game Scores of Season -->
          ${r.top_game_scores && r.top_game_scores.length > 0 ? `
            <div class="dashboard-card" style="grid-column: span 2;">
              <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                <h3 style="margin: 0; font-size: 1.2em;">🚀 Top Single-Game Scores (${season.year})</h3>
                <span class="category-tag">Single-Week Highs</span>
              </div>
              <table class="high-contrast-table">
                <thead>
                  <tr>
                    <th>Rank</th>
                    <th>Score</th>
                    <th>Manager</th>
                    <th>Team</th>
                    <th>Week</th>
                  </tr>
                </thead>
                <tbody>
                  ${r.top_game_scores.map((g, idx) => {
                    const rankLabel = idx === 0 ? '🥇 1' : (idx === 1 ? '🥈 2' : (idx === 2 ? '🥉 3' : `#${idx + 1}`));
                    return `
                      <tr>
                        <td style="font-weight: bold;">${rankLabel}</td>
                        <td style="font-weight: 800; color: #4caf50; font-size: 1.05em;">${parseFloat(g.points).toFixed(2)}</td>
                        <td>
                          <a href="{{ site.baseurl }}/teams/${g.user_id}/">${g.username}</a>
                        </td>
                        <td>${g.team_name}</td>
                        <td style="font-size: 0.85em; opacity: 0.8;">Week ${g.week}</td>
                      </tr>
                    `;
                  }).join('')}
                </tbody>
              </table>
            </div>
          ` : ''}

          <!-- Matchup Highlights (Highest Combined & Closest) -->
          <div class="dashboard-card" style="display: flex; flex-direction: column; gap: 20px;">
            ${r.highest_scoring_matchups && r.highest_scoring_matchups.length > 0 ? `
              <div>
                <h3 style="margin: 0 0 10px; font-size: 1.1em;">⚔️ Wildest Shootouts</h3>
                <div style="display: flex; flex-direction: column; gap: 8px;">
                  ${r.highest_scoring_matchups.map(m => `
                    <div style="padding: 8px 10px; background: rgba(255,255,255,0.03); border-radius: 8px; border: 1px solid var(--border-color); font-size: 0.88em;">
                      <div style="display: flex; justify-content: space-between; font-weight: bold; margin-bottom: 3px;">
                        <span><a href="{{ site.baseurl }}/teams/${m.winner.user_id}/">${m.winner.username}</a> (${m.winner_points.toFixed(1)}) def. <a href="{{ site.baseurl }}/teams/${m.loser.user_id}/">${m.loser.username}</a> (${m.loser_points.toFixed(1)})</span>
                        <span style="color: var(--link-color);">${m.total_points.toFixed(1)} pts</span>
                      </div>
                      <span style="font-size: 0.8em; opacity: 0.7;">Week ${m.week} Matchup</span>
                    </div>
                  `).join('')}
                </div>
              </div>
            ` : ''}

            ${r.closest_matchups && r.closest_matchups.length > 0 ? `
              <div style="border-top: 1px solid var(--border-color); padding-top: 15px;">
                <h3 style="margin: 0 0 10px; font-size: 1.1em;">🎯 Closest Nail-Biters</h3>
                <div style="display: flex; flex-direction: column; gap: 8px;">
                  ${r.closest_matchups.map(m => `
                    <div style="padding: 8px 10px; background: rgba(255,255,255,0.03); border-radius: 8px; border: 1px solid var(--border-color); font-size: 0.88em;">
                      <div style="display: flex; justify-content: space-between; font-weight: bold; margin-bottom: 3px;">
                        <span><a href="{{ site.baseurl }}/teams/${m.winner.user_id}/">${m.winner.username}</a> def. <a href="{{ site.baseurl }}/teams/${m.loser.user_id}/">${m.loser.username}</a></span>
                        <span style="color: #ff9800;">+${m.diff.toFixed(2)} pts</span>
                      </div>
                      <span style="font-size: 0.8em; opacity: 0.7;">Week ${m.week} (${m.winner_points.toFixed(2)} - ${m.loser_points.toFixed(2)})</span>
                    </div>
                  `).join('')}
                </div>
              </div>
            ` : ''}
          </div>
        </div>
      </div>
    `;
  }

  seasonSelector.addEventListener('change', (e) => {
    updateSeasonsDashboard(e.target.value);
    window.location.hash = e.target.value;
  });

  function handleRoute() {
    const hashYear = window.location.hash.substring(1);
    const initialYear = seasonsData[hashYear] ? hashYear : defaultSeasonYear;
    updateSeasonsDashboard(initialYear);
  }

  window.addEventListener('hashchange', handleRoute);
  window.addEventListener('load', handleRoute);
</script>


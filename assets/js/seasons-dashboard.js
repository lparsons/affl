/**
 * AFFL Seasons & Historical Standings Dashboard
 * Manages dynamic season switching, playoff clinches, podium cards, and matchup showcases.
 */

(function () {
  'use strict';

  const config = window.AFFL_SEASONS_CONFIG || {};
  const baseUrl = config.baseUrl || '';
  const defaultSeasonYear = config.defaultSeasonYear || '2026';
  const seasonsData = config.seasonsData || {};
  const currentDraftId = config.currentDraftId || '';
  const draftDateFormatted = config.draftDateFormatted || '';

  const seasonSelector = document.getElementById('season-selector');
  const title = document.getElementById('seasons-title');
  const label = document.getElementById('selected-season-label');
  const highlightsContainer = document.getElementById('season-highlights');
  const standingsContentContainer = document.getElementById('standings-content');

  if (!seasonSelector || !title || !label || !highlightsContainer || !standingsContentContainer) {
    return;
  }

  function computeClinchStatus(standings, totalWeeks = 14) {
    if (!standings || standings.length === 0) return {};

    const gamesPlayed = Math.max(...standings.map(t => {
      const parts = (t.record || "0-0").split("-");
      return (parseInt(parts[0], 10) || 0) + (parseInt(parts[1], 10) || 0);
    }));

    if (gamesPlayed === 0) return {};

    const remaining = Math.max(0, totalWeeks - gamesPlayed);

    const teamsWithBounds = standings.map((t, idx) => {
      const parts = (t.record || "0-0").split("-");
      const wins = parseInt(parts[0], 10) || 0;
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
      return (parseInt(t.wins, 10) || 0) + (parseInt(t.losses, 10) || 0) > 0;
    });

    title.textContent = `${year} Season Dashboard`;
    label.textContent = isComplete
      ? `${season.name} • Final Results`
      : `${season.name} • ${hasGames ? 'Regular Season in Progress' : 'Pre-Draft & Rosters'}`;
    seasonSelector.value = year;

    let highlightsHtml = '';
    let contentHtml = '';

    if (isComplete) {
      // 🏆 Final Podium Card
      if (season.podium) {
        highlightsHtml += `
          <div class="dashboard-card" style="grid-column: 1 / -1;">
            <h2>🏆 Final Podium</h2>
            <div style="display: flex; justify-content: space-around; align-items: flex-end; padding: 10px 0; gap: 20px; max-width: 620px; margin: 0 auto; width: 100%;">
              <div style="text-align: center; flex: 1; order: 2;">
                <p style="font-size: 2em; margin: 0;">🥇</p>
                <img src="${season.podium.first.avatar ? 'https://sleepercdn.com/avatars/thumbs/' + season.podium.first.avatar : 'https://sleepercdn.com/images/v2/icons/player_default.webp'}" style="width: 70px; height: 70px; border-radius: 50%; border: 3px solid #ffd700;" alt="${season.podium.first.team_name}">
                <p style="margin: 5px 0 0; font-weight: 800;"><a href="${baseUrl}/teams/${season.podium.first.user_id}/">${season.podium.first.team_name}</a></p>
                <p style="margin: 0; font-size: 0.8em; opacity: 0.7;">Champion (${season.podium.first.record})</p>
              </div>
              <div style="text-align: center; flex: 1; order: 1; opacity: 0.9;">
                <p style="font-size: 1.5em; margin: 0;">🥈</p>
                <img src="${season.podium.second.avatar ? 'https://sleepercdn.com/avatars/thumbs/' + season.podium.second.avatar : 'https://sleepercdn.com/images/v2/icons/player_default.webp'}" style="width: 55px; height: 55px; border-radius: 50%; border: 2px solid #c0c0c0;" alt="${season.podium.second.team_name}">
                <p style="margin: 5px 0 0; font-weight: bold; font-size: 0.9em;"><a href="${baseUrl}/teams/${season.podium.second.user_id}/">${season.podium.second.team_name}</a></p>
                <p style="margin: 0; font-size: 0.8em; opacity: 0.7;">Runner-Up (${season.podium.second.record})</p>
              </div>
              <div style="text-align: center; flex: 1; order: 3; opacity: 0.8;">
                <p style="font-size: 1.3em; margin: 0;">🥉</p>
                <img src="${season.podium.third.avatar ? 'https://sleepercdn.com/avatars/thumbs/' + season.podium.third.avatar : 'https://sleepercdn.com/images/v2/icons/player_default.webp'}" style="width: 50px; height: 50px; border-radius: 50%; border: 2px solid #cd7f32;" alt="${season.podium.third.team_name}">
                <p style="margin: 5px 0 0; font-weight: bold; font-size: 0.8em;"><a href="${baseUrl}/teams/${season.podium.third.user_id}/">${season.podium.third.team_name}</a></p>
                <p style="margin: 0; font-size: 0.8em; opacity: 0.7;">3rd Place (${season.podium.third.record})</p>
              </div>
            </div>
          </div>
        `;
      }

      // 🌟 Awards & Honors Card
      if (season.awards || season.toilet_bowl_winner) {
        highlightsHtml += `
          <div class="dashboard-card" style="grid-column: 1 / -1;">
            <h2>🌟 Season Honors</h2>
            <div class="dashboard-grid" style="grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 15px;">
        `;

        if (season.toilet_bowl_winner) {
          highlightsHtml += `
              <div style="padding: 12px 15px; background: rgba(255, 152, 0, 0.08); border: 1px solid rgba(255, 152, 0, 0.3); border-radius: 8px;">
                <p style="margin: 0; font-size: 0.8em; opacity: 0.7; text-transform: uppercase; font-weight: 800;">🚽 Toilet Bowl Winner (Pick #1 Post-Keepers)</p>
                <p style="margin: 4px 0 0; font-weight: bold; color: #ff9800; font-size: 1.05em;"><a href="${baseUrl}/teams/${season.toilet_bowl_winner.user_id}/">${season.toilet_bowl_winner.team_name}</a></p>
                <p style="margin: 2px 0 0; font-size: 0.85em; opacity: 0.8;">${season.toilet_bowl_winner.username} (${season.toilet_bowl_winner.record})</p>
              </div>
          `;
        }

        if (season.awards && season.awards.highest_game) {
          highlightsHtml += `
              <div style="padding: 12px 15px; background: rgba(76, 175, 80, 0.08); border: 1px solid rgba(76, 175, 80, 0.3); border-radius: 8px;">
                <p style="margin: 0; font-size: 0.8em; opacity: 0.7; text-transform: uppercase; font-weight: 800;">🚀 High Score of Year</p>
                <p style="margin: 4px 0 0; font-weight: bold; color: #4caf50; font-size: 1.05em;">${parseFloat(season.awards.highest_game.points).toFixed(2)} pts</p>
                <p style="margin: 2px 0 0; font-size: 0.85em;"><a href="${baseUrl}/teams/${season.awards.highest_game.user_id}/">${season.awards.highest_game.team_name}</a> (Week ${season.awards.highest_game.week})</p>
              </div>
          `;
        }

        if (season.awards && season.awards.regular_season_points_leader) {
          highlightsHtml += `
              <div style="padding: 12px 15px; background: rgba(42, 122, 226, 0.08); border: 1px solid rgba(42, 122, 226, 0.3); border-radius: 8px;">
                <p style="margin: 0; font-size: 0.8em; opacity: 0.7; text-transform: uppercase; font-weight: 800;">👑 Regular Season Points King</p>
                <p style="margin: 4px 0 0; font-weight: bold; color: var(--link-color); font-size: 1.05em;">${parseFloat(season.awards.regular_season_points_leader.points_for).toFixed(2)} pts</p>
                <p style="margin: 2px 0 0; font-size: 0.85em;"><a href="${baseUrl}/teams/${season.awards.regular_season_points_leader.user_id}/">${season.awards.regular_season_points_leader.team_name}</a></p>
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
          <div class="table-responsive">
            <table class="high-contrast-table">
              <thead>
                <tr>
                  <th style="width: 85px;">Rank</th>
                  <th>Team & Manager</th>
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
            <td style="font-weight: bold; white-space: nowrap;">${rankBadge}</td>
            <td>
              <div style="display: flex; align-items: center; gap: 10px;">
                <img src="${avatarUrl}" width="32" height="32" style="border-radius: 50%;" alt="${team.team_name}">
                <div>
                  <div style="font-weight: bold;"><a href="${baseUrl}/teams/${team.user_id}/">${team.team_name}</a></div>
                  <div style="font-size: 0.82em; opacity: 0.7;">${team.username}</div>
                </div>
              </div>
            </td>
            <td style="white-space: nowrap;">${team.record} <span style="opacity: 0.6; font-size: 0.85em;">${seedLabel}</span></td>
            <td>${team.points_for}</td>
            <td>${team.points_against}</td>
          </tr>
        `;
      });

      contentHtml += `</tbody></table></div></div>`;
      contentHtml += renderSeasonRecords(season);

    } else if (!hasGames) {
      // ⏳ PRE-DRAFT / PRE-SEASON VIEW (NO EMPTY TABLE!)
      const pick1Team = season.standings ? season.standings.find(t => t.draft_slot === 1) : null;
      const draftRoomId = season.draft_id || currentDraftId;

      highlightsHtml += `
        <div class="dashboard-card" style="grid-column: 1 / -1;">
          <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
            <div>
              <h2 style="margin: 0;">🏈 ${season.year} Season • Slow Snake Draft Launchpad</h2>
              <p style="margin: 6px 0 0; opacity: 0.85; line-height: 1.5;">
                12 Franchises split across Yin & Yang divisions. The slow snake draft begins on <strong>${draftDateFormatted}</strong>.
              </p>
            </div>
            <div style="display: flex; gap: 10px; flex-wrap: wrap;">
              <a href="https://sleeper.com/draft/nfl/${draftRoomId}?is_active=true" target="_blank" class="btn">🚀 Enter Sleeper Draft Room</a>
              <a href="${baseUrl}/schedule/" class="btn" style="background: rgba(255,255,255,0.1); color: var(--text-color) !important;">Milestones</a>
              <a href="${baseUrl}/rules/" class="btn" style="background: rgba(255,255,255,0.1); color: var(--text-color) !important;">Rules</a>
            </div>
          </div>
          ${pick1Team ? `
            <div style="margin-top: 15px; padding: 10px 14px; background: rgba(255, 152, 0, 0.08); border: 1px solid rgba(255, 152, 0, 0.25); border-radius: 8px; font-size: 0.88em; display: flex; align-items: center; gap: 10px;">
              <span style="font-size: 1.3em;">🎯</span>
              <span><strong>Pick #1 On the Clock:</strong> <a href="${baseUrl}/teams/${pick1Team.user_id}/"><strong>${pick1Team.team_name}</strong></a> (${pick1Team.username}) holds the #1 overall selection post-keepers!</span>
            </div>
          ` : ''}
        </div>
      `;

      // Group teams by Division for Division View
      const yinTeams = season.standings.filter(t => t.division === 1);
      const yangTeams = season.standings.filter(t => t.division === 2);

      contentHtml = `
        <div style="margin-top: 20px;">
          <!-- 🎯 Draft Order Board (Front & Center) -->
          <div class="dashboard-card" style="margin-bottom: 25px;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; flex-wrap: wrap; gap: 10px;">
              <div>
                <h3 style="margin: 0; font-size: 1.25em;">🎯 ${season.year} Draft Order Board</h3>
                <p style="margin: 3px 0 0; font-size: 0.85em; opacity: 0.7;">14-Round Slow Snake Draft • 1 Keeper Forfeits Round 1</p>
              </div>
              <a href="https://sleeper.com/draft/nfl/${draftRoomId}?is_active=true" target="_blank" class="btn" style="padding: 6px 14px; font-size: 0.85em;">Draft Room ↗</a>
            </div>
            <div class="table-responsive">
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
                          <img src="${avatarUrl}" width="28" height="28" style="border-radius: 50%;" alt="${t.team_name}">
                          <a href="${baseUrl}/teams/${t.user_id}/">${t.team_name}</a>
                        </td>
                        <td>${t.username}</td>
                        <td><span class="category-tag">${t.division_name || 'Yin'}</span></td>
                      </tr>
                    `;
                  }).join('')}
                </tbody>
              </table>
            </div>
          </div>

          <!-- ☯️ Division Alignments -->
          <div style="margin-bottom: 25px;">
            <h3 style="margin-bottom: 5px; font-size: 1.25em;">☯️ Division Alignments</h3>
            <p style="font-size: 0.9em; opacity: 0.7; margin-bottom: 15px;">12 Franchises split across Yin and Yang Divisions for the ${season.year} campaign</p>

            <div class="dashboard-grid">
              <!-- Yin Division Card -->
              <div class="dashboard-card" style="border-top: 4px solid var(--link-color);">
                <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 15px;">
                  <h4 style="margin: 0; font-size: 1.15em;">☯️ Yin Division</h4>
                  <span class="category-tag">6 Teams</span>
                </div>
                <div style="display: flex; flex-direction: column; gap: 10px;">
                  ${yinTeams.map(t => {
                    const avatarUrl = t.avatar ? `https://sleepercdn.com/avatars/thumbs/${t.avatar}` : `https://sleepercdn.com/images/v2/icons/player_default.webp`;
                    const draftBadge = t.draft_slot ? `<span class="badge-clinch badge-hunt" title="Draft Pick Slot">Pick #${t.draft_slot}</span>` : '';
                    return `
                      <div style="display: flex; align-items: center; justify-content: space-between; padding: 8px 10px; background: rgba(255,255,255,0.03); border-radius: 8px; border: 1px solid var(--border-color);">
                        <div style="display: flex; align-items: center; gap: 10px;">
                          <img src="${avatarUrl}" width="32" height="32" style="border-radius: 50%;" alt="${t.team_name}">
                          <div>
                            <p style="margin: 0; font-weight: bold; font-size: 0.92em;"><a href="${baseUrl}/teams/${t.user_id}/">${t.team_name}</a></p>
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
                  <h4 style="margin: 0; font-size: 1.15em;">☯️ Yang Division</h4>
                  <span class="category-tag" style="background: rgba(255, 152, 0, 0.15); color: #ff9800;">6 Teams</span>
                </div>
                <div style="display: flex; flex-direction: column; gap: 10px;">
                  ${yangTeams.map(t => {
                    const avatarUrl = t.avatar ? `https://sleepercdn.com/avatars/thumbs/${t.avatar}` : `https://sleepercdn.com/images/v2/icons/player_default.webp`;
                    const draftBadge = t.draft_slot ? `<span class="badge-clinch badge-hunt" title="Draft Pick Slot">Pick #${t.draft_slot}</span>` : '';
                    return `
                      <div style="display: flex; align-items: center; justify-content: space-between; padding: 8px 10px; background: rgba(255,255,255,0.03); border-radius: 8px; border: 1px solid var(--border-color);">
                        <div style="display: flex; align-items: center; gap: 10px;">
                          <img src="${avatarUrl}" width="32" height="32" style="border-radius: 50%;" alt="${t.team_name}">
                          <div>
                            <p style="margin: 0; font-weight: bold; font-size: 0.92em;"><a href="${baseUrl}/teams/${t.user_id}/">${t.team_name}</a></p>
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
          </div>

          <!-- Note about live standings activation -->
          <div style="margin-bottom: 25px; padding: 14px 18px; background: rgba(42, 122, 226, 0.08); border: 1px dashed var(--link-color); border-radius: 10px; font-size: 0.88em; color: var(--text-color); opacity: 0.9;">
            ℹ️ <strong>Live Standings Notice:</strong> Win-loss standings, total points, weekly high scores, and mathematical playoff clinch trackers will automatically activate on this page once NFL Week 1 matchups kick off in September.
          </div>

          <!-- 📋 League Configuration & Rules -->
          <div class="dashboard-card">
            <h3 style="margin-top: 0; font-size: 1.15em;">📋 League Configuration & Roster Rules</h3>
            <div style="font-size: 0.9em; opacity: 0.85; display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 12px; line-height: 1.5;">
              <div><strong>Roster:</strong> 1 QB, 2 RB, 2 WR, 1 TE, 1 FLEX, 1 K, 1 DEF, 5 BN</div>
              <div><strong>Keepers:</strong> 1 Keeper per team (Forfeits Round 1 pick)</div>
              <div><strong>Playoffs:</strong> Weeks 15–17 (Top 6 advance, Top 2 bye)</div>
              <div><strong>Toilet Bowl:</strong> Winner gets next year's <strong>Pick #1 (Post-Keepers)</strong></div>
            </div>
            <div style="margin-top: 14px; display: flex; gap: 10px;">
              <a href="${baseUrl}/rules/" style="font-size: 0.85em; text-decoration: underline;">View Full Constitution Rules &rarr;</a>
              <a href="${baseUrl}/schedule/" style="font-size: 0.85em; text-decoration: underline;">Milestone Calendar &rarr;</a>
            </div>
          </div>
        </div>
      `;

    } else {
      // 🏈 ACTIVE REGULAR SEASON IN PROGRESS (GAMES PLAYED)
      const topTeam = season.standings && season.standings.length > 0 ? season.standings[0] : null;
      const yinLeader = season.standings.find(t => t.division === 1 || (t.division_name && t.division_name.toLowerCase() === 'yin'));
      const yangLeader = season.standings.find(t => t.division === 2 || (t.division_name && t.division_name.toLowerCase() === 'yang'));
      const rec = season.records || {};
      const highScore = rec.high_score || (season.awards && season.awards.highest_game);
      const pointsLeader = rec.points_leader || (season.awards && season.awards.regular_season_points_leader);
      const closestGame = rec.closest;

      highlightsHtml += `
        <!-- 👑 Current #1 Seed Spotlight -->
        ${topTeam ? `
          <div class="dashboard-card" style="border-left: 4px solid #ffd700; display: flex; flex-direction: column; justify-content: space-between;">
            <div>
              <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                <span style="font-size: 0.75em; text-transform: uppercase; font-weight: 800; color: #ffd700;">👑 League Leader</span>
                <span class="category-tag">Seed #1</span>
              </div>
              <div style="display: flex; align-items: center; gap: 12px; margin-top: 4px;">
                <img src="${topTeam.avatar ? 'https://sleepercdn.com/avatars/thumbs/' + topTeam.avatar : 'https://sleepercdn.com/images/v2/icons/player_default.webp'}" alt="${topTeam.team_name}" width="42" height="42" style="border-radius: 50%; border: 2px solid #ffd700; flex-shrink: 0;">
                <div>
                  <div style="font-weight: 800; font-size: 1.05em;"><a href="${baseUrl}/teams/${topTeam.user_id}/">${topTeam.team_name}</a></div>
                  <div style="font-size: 0.85em; opacity: 0.75; margin-top: 2px;">${topTeam.username} • <strong>${topTeam.record}</strong></div>
                </div>
              </div>
            </div>
            <div style="margin-top: 10px; font-size: 0.8em; opacity: 0.7;">
              ${topTeam.points_for} PF • ${topTeam.division_name || (topTeam.division === 2 ? 'Yang' : 'Yin')} Division
            </div>
          </div>
        ` : ''}

        <!-- ☯️ Division Leaders Card (Top 2 Byes) -->
        <div class="dashboard-card" style="border-left: 4px solid var(--link-color); display: flex; flex-direction: column; justify-content: space-between;">
          <div>
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
              <span style="font-size: 0.75em; text-transform: uppercase; font-weight: 800; color: var(--link-color);">⭐ Division Leaders</span>
              <span class="category-tag">1st-Round Byes</span>
            </div>
            <div style="display: flex; flex-direction: column; gap: 8px; margin-top: 4px;">
              ${yinLeader ? `
                <div style="display: flex; justify-content: space-between; align-items: center; font-size: 0.88em;">
                  <span><strong>☯️ Yin:</strong> <a href="${baseUrl}/teams/${yinLeader.user_id}/">${yinLeader.team_name}</a> <span style="opacity: 0.7;">(${yinLeader.record})</span></span>
                  <span style="font-weight: 600; font-size: 0.85em;">${yinLeader.points_for} PF</span>
                </div>
              ` : ''}
              ${yangLeader ? `
                <div style="display: flex; justify-content: space-between; align-items: center; font-size: 0.88em;">
                  <span><strong>☯️ Yang:</strong> <a href="${baseUrl}/teams/${yangLeader.user_id}/">${yangLeader.team_name}</a> <span style="opacity: 0.7;">(${yangLeader.record})</span></span>
                  <span style="font-weight: 600; font-size: 0.85em;">${yangLeader.points_for} PF</span>
                </div>
              ` : ''}
            </div>
          </div>
          <div style="margin-top: 10px; font-size: 0.8em; opacity: 0.7;">
            Division leaders clinch Seeds 1 & 2 bye weeks
          </div>
        </div>

        <!-- 🚀 Season High Score or Points Leader Card -->
        ${highScore && parseFloat(highScore.points) > 0 ? `
          <div class="dashboard-card" style="border-left: 4px solid #4caf50; display: flex; flex-direction: column; justify-content: space-between;">
            <div>
              <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                <span style="font-size: 0.75em; text-transform: uppercase; font-weight: 800; color: #4caf50;">🚀 Season High Score</span>
                <span class="category-tag" style="background: rgba(76, 175, 80, 0.15); color: #4caf50;">Week ${highScore.week}</span>
              </div>
              <div style="font-size: 1.5em; font-weight: 800; color: #4caf50; line-height: 1.2;">
                ${parseFloat(highScore.points).toFixed(2)} <span style="font-size: 0.55em; opacity: 0.8; font-weight: 600;">pts</span>
              </div>
              <div style="margin-top: 4px; font-weight: bold; font-size: 0.9em;">
                <a href="${baseUrl}/teams/${highScore.user_id}/">${highScore.team_name}</a>
              </div>
              <div style="font-size: 0.8em; opacity: 0.7;">Managed by ${highScore.username}</div>
            </div>
            <div style="margin-top: 10px; font-size: 0.8em; opacity: 0.7;">
              Single-week record for ${season.year}
            </div>
          </div>
        ` : (pointsLeader && parseFloat(pointsLeader.points_for) > 0 ? `
          <div class="dashboard-card" style="border-left: 4px solid #4caf50; display: flex; flex-direction: column; justify-content: space-between;">
            <div>
              <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                <span style="font-size: 0.75em; text-transform: uppercase; font-weight: 800; color: #4caf50;">👑 Points Leader</span>
                <span class="category-tag">Total PF</span>
              </div>
              <div style="font-size: 1.5em; font-weight: 800; color: #4caf50; line-height: 1.2;">
                ${parseFloat(pointsLeader.points_for).toFixed(2)} <span style="font-size: 0.55em; opacity: 0.8; font-weight: 600;">pts</span>
              </div>
              <div style="margin-top: 4px; font-weight: bold; font-size: 0.9em;">
                <a href="${baseUrl}/teams/${pointsLeader.user_id}/">${pointsLeader.team_name}</a>
              </div>
              <div style="font-size: 0.8em; opacity: 0.7;">Managed by ${pointsLeader.username}</div>
            </div>
            <div style="margin-top: 10px; font-size: 0.8em; opacity: 0.7;">
              Cumulative offensive points leader
            </div>
          </div>
        ` : '')}

        <!-- 👑 Scoring King or Closest Game Card -->
        ${pointsLeader && parseFloat(pointsLeader.points_for) > 0 && (!highScore || highScore.user_id !== pointsLeader.user_id) ? `
          <div class="dashboard-card" style="border-left: 4px solid var(--link-color); display: flex; flex-direction: column; justify-content: space-between;">
            <div>
              <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                <span style="font-size: 0.75em; text-transform: uppercase; font-weight: 800; color: var(--link-color);">👑 Total Points King</span>
                <span class="category-tag">Total PF</span>
              </div>
              <div style="font-size: 1.5em; font-weight: 800; color: var(--link-color); line-height: 1.2;">
                ${parseFloat(pointsLeader.points_for).toFixed(2)} <span style="font-size: 0.55em; opacity: 0.8; font-weight: 600;">pts</span>
              </div>
              <div style="margin-top: 4px; font-weight: bold; font-size: 0.9em;">
                <a href="${baseUrl}/teams/${pointsLeader.user_id}/">${pointsLeader.team_name}</a>
              </div>
              <div style="font-size: 0.8em; opacity: 0.7;">Managed by ${pointsLeader.username}</div>
            </div>
            <div style="margin-top: 10px; font-size: 0.8em; opacity: 0.7;">
              Leading the league in scoring production
            </div>
          </div>
        ` : (closestGame && closestGame.diff > 0 ? `
          <div class="dashboard-card" style="border-left: 4px solid #ff9800; display: flex; flex-direction: column; justify-content: space-between;">
            <div>
              <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                <span style="font-size: 0.75em; text-transform: uppercase; font-weight: 800; color: #ff9800;">🎯 Closest Thriller</span>
                <span class="category-tag" style="background: rgba(255, 152, 0, 0.15); color: #ff9800;">Week ${closestGame.week}</span>
              </div>
              <div style="font-size: 1.5em; font-weight: 800; color: #ff9800; line-height: 1.2;">
                +${parseFloat(closestGame.diff).toFixed(2)} <span style="font-size: 0.55em; opacity: 0.8; font-weight: 600;">diff</span>
              </div>
              <div style="margin-top: 4px; font-size: 0.85em; font-weight: bold;">
                <a href="${baseUrl}/teams/${closestGame.winner.user_id}/">${closestGame.winner.username}</a> (${closestGame.winner_points.toFixed(1)}) def. <a href="${baseUrl}/teams/${closestGame.loser.user_id}/">${closestGame.loser.username}</a> (${closestGame.loser_points.toFixed(1)})
              </div>
            </div>
            <div style="margin-top: 10px; font-size: 0.8em; opacity: 0.7;">
              Closest nail-biter victory of ${season.year}
            </div>
          </div>
        ` : '')}
      `;

      const clinchMap = computeClinchStatus(season.standings);

      contentHtml = `
        <div class="dashboard-card" style="margin-top: 20px;">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; flex-wrap: wrap; gap: 10px;">
            <div>
              <h2 style="margin: 0;">📊 Standings & Playoff Picture</h2>
              <p style="font-size: 0.85em; opacity: 0.7; margin: 4px 0 0;">
                Top 6 advance to Championship Playoffs (Seeds 1 & 2 Bye) • Seeds 7–12 enter Toilet Bowl for Pick #1
              </p>
            </div>
            <div style="display: flex; gap: 6px; flex-wrap: wrap; align-items: center;">
              <span class="badge-clinch badge-bye">⭐ Bye</span>
              <span class="badge-clinch badge-playoffs">🟢 Clinched</span>
              <span class="badge-clinch badge-bubble">🟡 In Contention</span>
              <span class="badge-clinch badge-tb">🚽 Toilet Bowl</span>
            </div>
          </div>
          <div class="table-responsive">
            <table class="high-contrast-table">
              <thead>
                <tr>
                  <th style="width: 60px;">Seed</th>
                  <th>Team & Manager</th>
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
        const divName = team.division_name || (team.division === 2 ? 'Yang' : 'Yin');
        const isYang = team.division === 2 || divName.toLowerCase() === 'yang';
        const divBadge = isYang
          ? `<span class="category-tag" style="background: rgba(255, 152, 0, 0.15); color: #ff9800; font-size: 0.78em; padding: 1px 6px; font-weight: 600;">☯️ Yang</span>`
          : `<span class="category-tag" style="background: rgba(42, 122, 226, 0.15); color: var(--link-color); font-size: 0.78em; padding: 1px 6px; font-weight: 600;">☯️ Yin</span>`;

        if (index === 6) {
          contentHtml += `
            <tr class="playoff-cutline-row">
              <td colspan="6">
                ⬆️ Top 6 Championship Playoffs (Seeds 1 & 2 Bye) • ⬇️ Bottom 6 Toilet Bowl Bracket (Pick #1 Post-Keepers)
              </td>
            </tr>
          `;
        }

        contentHtml += `
          <tr>
            <td style="font-weight: bold; white-space: nowrap;">#${index + 1}</td>
            <td>
              <div style="display: flex; align-items: center; gap: 10px;">
                <img src="${avatarUrl}" width="32" height="32" style="border-radius: 50%;" alt="${team.team_name}">
                <div>
                  <div style="font-weight: bold;"><a href="${baseUrl}/teams/${team.user_id}/">${team.team_name}</a></div>
                  <div style="font-size: 0.82em; opacity: 0.75; display: flex; align-items: center; gap: 6px; margin-top: 2px;">
                    <span>${team.username}</span>
                    <span>•</span>
                    ${divBadge}
                  </div>
                </div>
              </div>
            </td>
            <td style="white-space: nowrap; font-weight: 600;">${team.record}</td>
            <td>${clinch ? `<span class="${clinch.badgeClass}">${clinch.icon}</span>` : '-'}</td>
            <td>${team.points_for}</td>
            <td>${team.points_against}</td>
          </tr>
        `;
      });

      contentHtml += `</tbody></table></div></div>`;
      contentHtml += renderSeasonRecords(season);

      // Boilerplate Postseason Rules & Stakes moved to bottom reference
      contentHtml += `
        <div style="margin-top: 30px;">
          <h2 style="margin-bottom: 15px;">📜 Postseason Format, Seeding & Stakes</h2>
          <div class="dashboard-grid">
            <div class="dashboard-card">
              <h3 style="margin-top: 0; font-size: 1.15em;">🏆 Postseason Stakes</h3>
              <p style="font-size: 0.9em; opacity: 0.85; margin: 0; line-height: 1.6;">
                • <strong>Weeks 1–14:</strong> 14-game Regular Season.<br>
                • <strong>Weeks 15–17:</strong> 3-round Championship & Toilet Bowl Brackets.<br>
                • <strong>Championship:</strong> Winner earns the AFFL Trophy & ultimate league glory.<br>
                • <strong>Toilet Bowl:</strong> Winner claims next year's <strong>Pick #1 (Post-Keepers)</strong>.
              </p>
            </div>
            <div class="dashboard-card">
              <h3 style="margin-top: 0; font-size: 1.15em;">⚖️ Playoff Structure & Seeding</h3>
              <p style="font-size: 0.9em; opacity: 0.85; margin: 0; line-height: 1.6;">
                • <strong>Seeds 1 & 2:</strong> Top 2 teams (Division Winners) earn 1st-round byes.<br>
                • <strong>Seeds 3–6:</strong> Next best regular season records advance to Wild Card round.<br>
                • <strong>Tiebreakers:</strong> 1. Overall Record, 2. Total Points For (PF), 3. Head-to-Head record.<br>
                • <a href="${baseUrl}/rules/" style="text-decoration: underline;">View Full Constitution Rules &rarr;</a>
              </p>
            </div>
          </div>
          <div style="margin-top: 15px; padding: 12px 16px; background: rgba(42, 122, 226, 0.08); border-radius: 8px; font-size: 0.85em; opacity: 0.85;">
            ℹ️ Standings, weekly scores, and clinch trackers update automatically throughout the week (Tuesdays–Thursdays as Sleeper records and official stat corrections finalize).
          </div>
        </div>
      `;
    }

    highlightsContainer.innerHTML = highlightsHtml;
    standingsContentContainer.innerHTML = contentHtml;
  }

  function renderSeasonRecords(season) {
    if (!season.records) return '';
    const r = season.records;

    const validTopScores = (r.top_game_scores || []).filter(g => parseFloat(g.points) > 0);
    const validShootouts = (r.highest_scoring_matchups || []).filter(m => (m.total_points || 0) > 0 && (m.winner_points || 0) > 0 && (m.loser_points || 0) > 0);
    const validNailBiters = (r.closest_matchups || []).filter(m => (m.total_points || 0) > 0 && (m.winner_points || 0) > 0 && (m.loser_points || 0) > 0);

    return `
      <div style="margin-top: 30px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; flex-wrap: wrap; gap: 10px;">
          <h2 style="margin: 0;">📊 ${season.year} Season Records & Superlatives</h2>
          <span class="category-tag">${season.year} Milestones</span>
        </div>

        <!-- Superlatives Summary Grid -->
        <div class="dashboard-grid" style="grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 15px; margin-bottom: 20px;">
          ${r.high_score && parseFloat(r.high_score.points) > 0 ? `
            <div class="dashboard-card" style="padding: 15px; border-left: 4px solid #4caf50;">
              <p style="margin: 0; font-size: 0.75em; color: #4caf50; text-transform: uppercase; font-weight: 800;">🚀 Season High Score</p>
              <p style="margin: 4px 0 0; font-size: 1.25em; font-weight: 800; color: #4caf50;">${parseFloat(r.high_score.points).toFixed(2)} pts</p>
              <p style="margin: 2px 0 0; font-size: 0.85em;"><a href="${baseUrl}/teams/${r.high_score.user_id}/"><strong>${r.high_score.username}</strong></a> (${r.high_score.team_name}, Wk ${r.high_score.week})</p>
            </div>
          ` : ''}

          ${r.points_leader && parseFloat(r.points_leader.points_for) > 0 ? `
            <div class="dashboard-card" style="padding: 15px; border-left: 4px solid var(--link-color);">
              <p style="margin: 0; font-size: 0.75em; color: var(--link-color); text-transform: uppercase; font-weight: 800;">👑 Total Points Leader</p>
              <p style="margin: 4px 0 0; font-size: 1.25em; font-weight: 800; color: var(--link-color);">${parseFloat(r.points_leader.points_for).toFixed(2)} pts</p>
              <p style="margin: 2px 0 0; font-size: 0.85em;"><a href="${baseUrl}/teams/${r.points_leader.user_id}/"><strong>${r.points_leader.username}</strong></a> (${r.points_leader.team_name})</p>
            </div>
          ` : ''}

          ${r.best_record && ((parseInt(r.best_record.wins, 10) || 0) + (parseInt(r.best_record.losses, 10) || 0) > 0) ? `
            <div class="dashboard-card" style="padding: 15px; border-left: 4px solid #ffd700;">
              <p style="margin: 0; font-size: 0.75em; color: #ffd700; text-transform: uppercase; font-weight: 800;">⭐ Best Regular Record</p>
              <p style="margin: 4px 0 0; font-size: 1.25em; font-weight: 800;">${r.best_record.record}</p>
              <p style="margin: 2px 0 0; font-size: 0.85em;"><a href="${baseUrl}/teams/${r.best_record.user_id}/"><strong>${r.best_record.username}</strong></a> (${r.best_record.team_name})</p>
            </div>
          ` : ''}

          ${r.pa_leader && parseFloat(r.pa_leader.points_against) > 0 ? `
            <div class="dashboard-card" style="padding: 15px; border-left: 4px solid #f44336;">
              <p style="margin: 0; font-size: 0.75em; color: #f44336; text-transform: uppercase; font-weight: 800;">🛡️ Toughest Schedule (Most PA)</p>
              <p style="margin: 4px 0 0; font-size: 1.25em; font-weight: 800;">${parseFloat(r.pa_leader.points_against).toFixed(2)} pts</p>
              <p style="margin: 2px 0 0; font-size: 0.85em;"><a href="${baseUrl}/teams/${r.pa_leader.user_id}/"><strong>${r.pa_leader.username}</strong></a> (${r.pa_leader.team_name})</p>
            </div>
          ` : ''}
        </div>

        <div class="dashboard-grid" style="grid-template-columns: 1fr; gap: 20px;">
          <!-- Top Single-Game Scores of Season -->
          ${validTopScores.length > 0 ? `
            <div class="dashboard-card">
              <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                <h3 style="margin: 0; font-size: 1.2em;">🚀 Top Single-Game Scores (${season.year})</h3>
                <span class="category-tag">Single-Week Highs</span>
              </div>
              <div class="table-responsive">
                <table class="high-contrast-table">
                  <thead>
                    <tr>
                      <th style="width: 70px;">Rank</th>
                      <th>Score</th>
                      <th>Manager</th>
                      <th>Team</th>
                      <th>Week</th>
                    </tr>
                  </thead>
                  <tbody>
                    ${validTopScores.map((g, idx) => {
                      const rankLabel = idx === 0 ? '🥇 1' : (idx === 1 ? '🥈 2' : (idx === 2 ? '🥉 3' : `#${idx + 1}`));
                      return `
                        <tr>
                          <td style="font-weight: bold; white-space: nowrap;">${rankLabel}</td>
                          <td style="font-weight: 800; color: #4caf50; font-size: 1.05em; white-space: nowrap;">${parseFloat(g.points).toFixed(2)}</td>
                          <td>
                            <a href="${baseUrl}/teams/${g.user_id}/">${g.username}</a>
                          </td>
                          <td>${g.team_name}</td>
                          <td style="font-size: 0.85em; opacity: 0.8; white-space: nowrap;">Week ${g.week}</td>
                        </tr>
                      `;
                    }).join('')}
                  </tbody>
                </table>
              </div>
            </div>
          ` : ''}

          <!-- Matchup Highlights (Highest Combined & Closest) -->
          ${(validShootouts.length > 0 || validNailBiters.length > 0) ? `
          <div class="dashboard-card">
            <h3 style="margin: 0 0 15px; font-size: 1.2em;">⚔️ Season Matchup Showcases</h3>
            <div class="dashboard-grid">
              ${validShootouts.length > 0 ? `
                <div>
                  <h4 style="margin: 0 0 10px; font-size: 1.05em; color: var(--link-color);">💥 Wildest Shootouts</h4>
                  <div style="display: flex; flex-direction: column; gap: 8px;">
                    ${validShootouts.map(m => `
                      <div style="padding: 8px 10px; background: rgba(255,255,255,0.03); border-radius: 8px; border: 1px solid var(--border-color); font-size: 0.88em;">
                        <div style="display: flex; justify-content: space-between; font-weight: bold; margin-bottom: 3px;">
                          <span><a href="${baseUrl}/teams/${m.winner.user_id}/">${m.winner.username}</a> (${m.winner_points.toFixed(1)}) def. <a href="${baseUrl}/teams/${m.loser.user_id}/">${m.loser.username}</a> (${m.loser_points.toFixed(1)})</span>
                          <span style="color: var(--link-color);">${m.total_points.toFixed(1)} pts</span>
                        </div>
                        <span style="font-size: 0.8em; opacity: 0.7;">Week ${m.week} Matchup</span>
                      </div>
                    `).join('')}
                  </div>
                </div>
              ` : ''}

              ${validNailBiters.length > 0 ? `
                <div>
                  <h4 style="margin: 0 0 10px; font-size: 1.05em; color: #ff9800;">🎯 Closest Nail-Biters</h4>
                  <div style="display: flex; flex-direction: column; gap: 8px;">
                    ${validNailBiters.map(m => `
                      <div style="padding: 8px 10px; background: rgba(255,255,255,0.03); border-radius: 8px; border: 1px solid var(--border-color); font-size: 0.88em;">
                        <div style="display: flex; justify-content: space-between; font-weight: bold; margin-bottom: 3px;">
                          <span><a href="${baseUrl}/teams/${m.winner.user_id}/">${m.winner.username}</a> def. <a href="${baseUrl}/teams/${m.loser.user_id}/">${m.loser.username}</a></span>
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
          ` : ''}
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
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', handleRoute);
  } else {
    handleRoute();
  }
})();

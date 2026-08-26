---
layout: page
title: Franchises & Teams
permalink: /teams/
---

<div class="dashboard-container">
  <!-- Page Header -->
  <div class="dashboard-header" style="justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 15px;">
    <div>
      <h1 style="margin: 0;">AFFL Franchises & Teams</h1>
      <p style="margin: 5px 0 0; opacity: 0.85;">
        Every team in the league is anchored to a permanent manager franchise. While team names and branding change from week to week and season to season, all career records, head-to-head battles, and trophies remain linked to each owner.
      </p>
    </div>
    <div style="display: flex; gap: 10px; flex-wrap: wrap;">
      <a href="{{ site.baseurl }}/records/" class="btn" style="padding: 8px 14px; font-size: 0.9em;">Record Book ↗</a>
      <a href="{{ site.baseurl }}/history/" class="btn" style="padding: 8px 14px; font-size: 0.9em; background: rgba(255,255,255,0.08); color: var(--text-color) !important;">Hall of Champions ↗</a>
    </div>
  </div>

  <!-- League Franchise Stats Banner -->
  <div class="dashboard-grid" style="grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 12px; margin-bottom: 25px;">
    <div class="dashboard-card" style="padding: 12px 15px; border-left: 4px solid var(--link-color);">
      <p style="margin: 0; font-size: 0.75em; opacity: 0.7; text-transform: uppercase; font-weight: bold;">Active Franchises</p>
      <p style="margin: 2px 0 0; font-size: 1.4em; font-weight: 800; color: var(--link-color);">12 Teams</p>
      <p style="margin: 0; font-size: 0.8em; opacity: 0.7;">{{ site.current_season }} Campaign</p>
    </div>
    <div class="dashboard-card" style="padding: 12px 15px; border-left: 4px solid #9c27b0;">
      <p style="margin: 0; font-size: 0.75em; opacity: 0.7; text-transform: uppercase; font-weight: bold;">All-Time Franchises</p>
      <p style="margin: 2px 0 0; font-size: 1.4em; font-weight: 800; color: #9c27b0;">{{ site.data.all_teams.size }} Owners</p>
      <p style="margin: 0; font-size: 0.8em; opacity: 0.7;">2019–Present</p>
    </div>
    <div class="dashboard-card" style="padding: 12px 15px; border-left: 4px solid #ffd700;">
      <p style="margin: 0; font-size: 0.75em; opacity: 0.7; text-transform: uppercase; font-weight: bold;">Championship Banners</p>
      <p style="margin: 2px 0 0; font-size: 1.4em; font-weight: 800; color: #ffd700;">6 Titles Won</p>
      <p style="margin: 0; font-size: 0.8em; opacity: 0.7;">Across 5 Unique Owners</p>
    </div>
    <div class="dashboard-card" style="padding: 12px 15px; border-left: 4px solid #4caf50;">
      <p style="margin: 0; font-size: 0.75em; opacity: 0.7; text-transform: uppercase; font-weight: bold;">All-Time Win Leader</p>
      {% assign top_winner = site.data.all_teams | first %}
      <p style="margin: 2px 0 0; font-size: 1.2em; font-weight: 800; color: #4caf50;">{{ top_winner.stats.wins }} Wins</p>
      <p style="margin: 0; font-size: 0.8em; opacity: 0.8;">{{ top_winner.username }}</p>
    </div>
  </div>

  <!-- Search / Filter Bar -->
  <div style="margin-bottom: 25px; background: var(--card-bg); padding: 12px 18px; border-radius: 12px; border: 1px solid var(--border-color); display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 15px;">
    <div style="display: flex; align-items: center; gap: 10px; flex: 1; min-width: 260px;">
      <span style="font-size: 1.2em;">🔍</span>
      <input type="text" id="franchise-search" placeholder="Search by manager, current team name, past aliases, or division..." style="width: 100%; padding: 8px 12px; border-radius: 8px; background: var(--header-bg); color: var(--text-color); border: 1px solid var(--border-color); font-size: 0.95em;">
    </div>
    <div style="display: flex; gap: 8px; align-items: center; font-size: 0.85em; opacity: 0.8;">
      <span>Sort by:</span>
      <button class="sort-btn active" data-sort="wins" onclick="sortFranchises('wins', this)">All-Time Wins</button>
      <button class="sort-btn" data-sort="pct" onclick="sortFranchises('pct', this)">Win %</button>
      <button class="sort-btn" data-sort="points" onclick="sortFranchises('points', this)">Career Points</button>
    </div>
  </div>

  <!-- Active Franchises Section -->
  <div style="margin-bottom: 35px;">
    <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 15px;">
      <h2 style="margin: 0;">⚡ Active Franchises ({{ site.current_season }} Season)</h2>
      <span class="category-tag">12 Competing Teams</span>
    </div>

    <div class="dashboard-grid" id="active-franchises-grid" style="grid-template-columns: repeat(auto-fit, minmax(340px, 1fr)); gap: 20px;">
      {% for team in site.data.all_teams %}
        {% if team.is_active %}
          {% if team.current_avatar %}
            {% assign avatar_url = "https://sleepercdn.com/avatars/thumbs/" | append: team.current_avatar %}
          {% else %}
            {% assign avatar_url = "https://sleepercdn.com/images/v2/icons/player_default.webp" %}
          {% endif %}
          
          <div class="dashboard-card franchise-card" 
               data-wins="{{ team.stats.wins }}" 
               data-pct="{{ team.stats.win_pct }}" 
               data-points="{{ team.stats.points_for }}" 
               data-search="{{ team.username | downcase }} {{ team.current_team_name | downcase }} {{ team.past_names | join: ' ' | downcase }} {{ team.current_division_name | downcase }}"
               style="display: flex; flex-direction: column; justify-content: space-between; position: relative;">
            
            <div>
              <!-- Top Row: Avatar, Names, Badges -->
              <div style="display: flex; align-items: flex-start; justify-content: space-between; gap: 12px; margin-bottom: 12px;">
                <div style="display: flex; align-items: center; gap: 12px;">
                  <img src="{{ avatar_url }}" width="50" height="50" style="border-radius: 50%; border: 2px solid var(--border-color);" alt="{{ team.username }}">
                  <div>
                    <h3 style="margin: 0; font-size: 1.15em;">
                      <a href="{{ site.baseurl }}/teams/{{ team.user_id }}/">{{ team.current_team_name }}</a>
                    </h3>
                    <p style="margin: 2px 0 0; font-size: 0.85em; opacity: 0.8;">
                      Manager: <strong><a href="{{ site.baseurl }}/teams/{{ team.user_id }}/">{{ team.username }}</a></strong>
                    </p>
                  </div>
                </div>

                <div style="text-align: right; display: flex; flex-direction: column; align-items: flex-end; gap: 4px;">
                  {% if team.current_division_name == 'Yin' %}
                    <span class="category-tag" style="background: rgba(42, 122, 226, 0.15); color: var(--link-color);">☯️ Yin Division</span>
                  {% elsif team.current_division_name == 'Yang' %}
                    <span class="category-tag" style="background: rgba(255, 152, 0, 0.15); color: #ff9800;">☯️ Yang Division</span>
                  {% endif %}
                  <span style="font-size: 0.75em; opacity: 0.65;">{{ team.years_span }} ({{ team.seasons_count }} yrs)</span>
                </div>
              </div>

              <!-- Past Aliases / Historical Team Names -->
              <div style="margin: 10px 0; padding: 8px 10px; background: rgba(255,255,255,0.03); border: 1px solid var(--border-color); border-radius: 6px; font-size: 0.82em;">
                <span style="opacity: 0.6; text-transform: uppercase; font-weight: bold; font-size: 0.75em; display: block; margin-bottom: 3px;">🏷️ Known Team Aliases:</span>
                {% if team.past_names and team.past_names.size > 0 %}
                  <div style="display: flex; flex-wrap: wrap; gap: 4px;">
                    {% for alias in team.past_names %}
                      <span style="background: rgba(255,255,255,0.06); padding: 2px 6px; border-radius: 4px; opacity: 0.9;">{{ alias }}</span>
                    {% endfor %}
                  </div>
                {% else %}
                  <span style="opacity: 0.7; font-style: italic;">Always known as {{ team.current_team_name }}</span>
                {% endif %}
              </div>

              <!-- Career Key Stats Grid -->
              <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 6px; text-align: center; margin: 12px 0; padding: 8px 0; background: rgba(0,0,0,0.1); border-radius: 8px; border: 1px solid var(--border-color);">
                <div>
                  <span style="font-size: 0.7em; opacity: 0.6; text-transform: uppercase; display: block;">Record</span>
                  <strong style="font-size: 0.95em;">{{ team.stats.wins }}-{{ team.stats.losses }}</strong>
                </div>
                <div>
                  <span style="font-size: 0.7em; opacity: 0.6; text-transform: uppercase; display: block;">Win %</span>
                  <strong style="font-size: 0.95em; color: var(--link-color);">{{ team.stats.win_pct }}%</strong>
                </div>
                <div>
                  <span style="font-size: 0.7em; opacity: 0.6; text-transform: uppercase; display: block;">Career PF</span>
                  <strong style="font-size: 0.95em;">{{ team.stats.points_for | round: 0 }}</strong>
                </div>
                <div>
                  <span style="font-size: 0.7em; opacity: 0.6; text-transform: uppercase; display: block;">Avg / Gm</span>
                  <strong style="font-size: 0.95em; color: #4caf50;">{{ team.stats.avg_points | round: 1 }}</strong>
                </div>
              </div>

              <!-- Trophy Cabinet Badges -->
              <div style="display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 15px; font-size: 0.82em;">
                {% if team.stats.championships > 0 %}
                  <span style="background: rgba(255,215,0,0.15); color: #ffd700; border: 1px solid rgba(255,215,0,0.4); padding: 3px 8px; border-radius: 6px; font-weight: bold;">
                    🏆 {{ team.stats.championships }} {% if team.stats.championships == 1 %}Title{% else %}Titles{% endif %}
                  </span>
                {% endif %}
                {% if team.stats.runner_ups > 0 %}
                  <span style="background: rgba(192,192,192,0.15); color: #c0c0c0; border: 1px solid rgba(192,192,192,0.4); padding: 3px 8px; border-radius: 6px; font-weight: bold;">
                    🥈 {{ team.stats.runner_ups }} Runner-Up
                  </span>
                {% endif %}
                {% if team.stats.toilet_bowls > 0 %}
                  <span style="background: rgba(255,152,0,0.15); color: #ff9800; border: 1px solid rgba(255,152,0,0.4); padding: 3px 8px; border-radius: 6px; font-weight: bold;">
                    🚽 {{ team.stats.toilet_bowls }} Toilet Bowl
                  </span>
                {% endif %}
                {% if team.stats.championships == 0 and team.stats.runner_ups == 0 and team.stats.toilet_bowls == 0 %}
                  <span style="opacity: 0.5; font-style: italic;">Chasing first league trophy</span>
                {% endif %}
              </div>
            </div>

            <!-- Profile CTA Button -->
            <a href="{{ site.baseurl }}/teams/{{ team.user_id }}/" class="btn" style="text-align: center; width: 100%; box-sizing: border-box; padding: 7px 0; font-size: 0.88em;">
              View Career Profile & H2H &rarr;
            </a>
          </div>
        {% endif %}
      {% endfor %}
    </div>
  </div>

  <!-- Historical / Alumni Franchises Section -->
  <div style="margin-top: 40px;">
    <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 15px;">
      <div>
        <h2 style="margin: 0;">🏛️ Historical Franchises & League Alumni</h2>
        <p style="margin: 4px 0 0; font-size: 0.85em; opacity: 0.7;">Franchises that competed in past AFFL campaigns</p>
      </div>
      <span class="category-tag" style="background: rgba(156, 39, 176, 0.15); color: #9c27b0;">Alumni Registry</span>
    </div>

    <div class="dashboard-grid" id="historical-franchises-grid" style="grid-template-columns: repeat(auto-fit, minmax(340px, 1fr)); gap: 20px;">
      {% for team in site.data.all_teams %}
        {% unless team.is_active %}
          {% if team.current_avatar %}
            {% assign avatar_url = "https://sleepercdn.com/avatars/thumbs/" | append: team.current_avatar %}
          {% else %}
            {% assign avatar_url = "https://sleepercdn.com/images/v2/icons/player_default.webp" %}
          {% endif %}
          
          <div class="dashboard-card franchise-card" 
               data-wins="{{ team.stats.wins }}" 
               data-pct="{{ team.stats.win_pct }}" 
               data-points="{{ team.stats.points_for }}" 
               data-search="{{ team.username | downcase }} {{ team.current_team_name | downcase }} {{ team.past_names | join: ' ' | downcase }}"
               style="display: flex; flex-direction: column; justify-content: space-between; position: relative; border-left: 4px solid #9c27b0;">
            
            <div>
              <div style="display: flex; align-items: flex-start; justify-content: space-between; gap: 12px; margin-bottom: 12px;">
                <div style="display: flex; align-items: center; gap: 12px;">
                  <img src="{{ avatar_url }}" width="50" height="50" style="border-radius: 50%; border: 2px solid var(--border-color);" alt="{{ team.username }}">
                  <div>
                    <h3 style="margin: 0; font-size: 1.15em;">
                      <a href="{{ site.baseurl }}/teams/{{ team.user_id }}/">{{ team.current_team_name }}</a>
                    </h3>
                    <p style="margin: 2px 0 0; font-size: 0.85em; opacity: 0.8;">
                      Manager: <strong><a href="{{ site.baseurl }}/teams/{{ team.user_id }}/">{{ team.username }}</a></strong>
                    </p>
                  </div>
                </div>

                <div style="text-align: right;">
                  <span class="category-tag" style="background: rgba(156, 39, 176, 0.15); color: #9c27b0;">Alumni</span>
                  <span style="font-size: 0.75em; opacity: 0.65; display: block; margin-top: 4px;">{{ team.years_span }} Season</span>
                </div>
              </div>

              <!-- Past Aliases -->
              <div style="margin: 10px 0; padding: 8px 10px; background: rgba(255,255,255,0.03); border: 1px solid var(--border-color); border-radius: 6px; font-size: 0.82em;">
                <span style="opacity: 0.6; text-transform: uppercase; font-weight: bold; font-size: 0.75em; display: block; margin-bottom: 3px;">🏷️ Known Team Aliases:</span>
                {% if team.all_names and team.all_names.size > 0 %}
                  <div style="display: flex; flex-wrap: wrap; gap: 4px;">
                    {% for alias in team.all_names %}
                      <span style="background: rgba(255,255,255,0.06); padding: 2px 6px; border-radius: 4px; opacity: 0.9;">{{ alias }}</span>
                    {% endfor %}
                  </div>
                {% else %}
                  <span style="opacity: 0.7; font-style: italic;">{{ team.current_team_name }}</span>
                {% endif %}
              </div>

              <!-- Career Key Stats Grid -->
              <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 6px; text-align: center; margin: 12px 0; padding: 8px 0; background: rgba(0,0,0,0.1); border-radius: 8px; border: 1px solid var(--border-color);">
                <div>
                  <span style="font-size: 0.7em; opacity: 0.6; text-transform: uppercase; display: block;">Record</span>
                  <strong style="font-size: 0.95em;">{{ team.stats.wins }}-{{ team.stats.losses }}</strong>
                </div>
                <div>
                  <span style="font-size: 0.7em; opacity: 0.6; text-transform: uppercase; display: block;">Win %</span>
                  <strong style="font-size: 0.95em; color: var(--link-color);">{{ team.stats.win_pct }}%</strong>
                </div>
                <div>
                  <span style="font-size: 0.7em; opacity: 0.6; text-transform: uppercase; display: block;">Career PF</span>
                  <strong style="font-size: 0.95em;">{{ team.stats.points_for | round: 0 }}</strong>
                </div>
                <div>
                  <span style="font-size: 0.7em; opacity: 0.6; text-transform: uppercase; display: block;">Best Finish</span>
                  <strong style="font-size: 0.95em; color: #4caf50;">#{{ team.stats.best_finish }}</strong>
                </div>
              </div>
            </div>

            <!-- Profile CTA Button -->
            <a href="{{ site.baseurl }}/teams/{{ team.user_id }}/" class="btn" style="text-align: center; width: 100%; box-sizing: border-box; padding: 7px 0; font-size: 0.88em; background: rgba(255,255,255,0.08); color: var(--text-color) !important;">
              View Historical Archive &rarr;
            </a>
          </div>
        {% endunless %}
      {% endfor %}
    </div>
  </div>
</div>

<style>
  .sort-btn {
    background: rgba(255,255,255,0.05);
    border: 1px solid var(--border-color);
    color: var(--text-color);
    padding: 4px 10px;
    border-radius: 6px;
    cursor: pointer;
    font-size: 0.85em;
    transition: all 0.2s ease;
  }
  .sort-btn.active {
    background: var(--link-color);
    color: #fff;
    border-color: var(--link-color);
  }
</style>

<script>
  const searchInput = document.getElementById('franchise-search');
  const cards = document.querySelectorAll('.franchise-card');

  searchInput.addEventListener('input', (e) => {
    const query = e.target.value.toLowerCase().trim();
    cards.forEach(card => {
      const searchData = card.getAttribute('data-search') || '';
      if (searchData.includes(query)) {
        card.style.display = 'flex';
      } else {
        card.style.display = 'none';
      }
    });
  });

  function sortFranchises(criteria, btn) {
    document.querySelectorAll('.sort-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');

    ['active-franchises-grid', 'historical-franchises-grid'].forEach(gridId => {
      const grid = document.getElementById(gridId);
      if (!grid) return;
      const gridCards = Array.from(grid.querySelectorAll('.franchise-card'));
      
      gridCards.sort((a, b) => {
        let valA = parseFloat(a.getAttribute(`data-${criteria}`)) || 0;
        let valB = parseFloat(b.getAttribute(`data-${criteria}`)) || 0;
        return valB - valA;
      });

      gridCards.forEach(card => grid.appendChild(card));
    });
  }
</script>

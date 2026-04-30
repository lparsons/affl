---
layout: page
---

<div class="dashboard-container">
  <!-- League Branded Header -->
  <div class="dashboard-header">
    {% if site.league_logo %}
      <img src="{{ site.league_logo }}" alt="{{ site.league_name }}" style="max-width: 120px;">
    {% endif %}
    <div>
      <h1 style="margin: 0;">{{ site.league_name }}</h1>
      <p style="margin: 5px 0 0; opacity: 0.8;">{{ site.league_state | replace: '_', ' ' | capitalize }} Phase • {{ site.current_season }} Season</p>
    </div>
  </div>

  <!-- Dynamic Content Area -->
  <div class="dashboard-content">
    {% if site.league_state == 'offseason' %}
      {% include home/offseason.html %}
    {% elsif site.league_state == 'predraft' %}
      {% include home/predraft.html %}
    {% elsif site.league_state == 'regular_season' %}
      {% include home/regular_season.html %}
    {% elsif site.league_state == 'playoffs' %}
      {% include home/playoffs.html %}
    {% else %}
      <div class="dashboard-card">
        <h2>Welcome</h2>
        <p>Official website for the AFFL hosted on Sleeper.</p>
      </div>
    {% endif %}
  </div>

  <div class="dashboard-grid">
    <div class="dashboard-card">
      <h2>Quick Navigation</h2>
      <ul style="margin: 0; padding-left: 20px;">
        <li><a href="{{ site.baseurl }}/seasons/">Seasons Dashboard</a></li>
        <li><a href="{{ site.baseurl }}/records/">League Record Book</a></li>
        <li><a href="{{ site.baseurl }}/history/">Hall of Champions</a></li>
        <li><a href="{{ site.baseurl }}/rules/">Official Rules</a></li>
      </ul>
    </div>
    
    <div class="dashboard-card">
      <h2>External Links</h2>
      <ul style="margin: 0; padding-left: 20px;">
        <li><a href="https://sleeper.com/leagues/{{ site.current_league_id }}" target="_blank">League on Sleeper</a></li>
        <li><a href="https://sleeper.com/leagues/{{ site.current_league_id }}/matchup" target="_blank">Current Matchups</a></li>
      </ul>
    </div>
  </div>
</div>

<script>
  // Add class to body for specific CSS targeting
  document.body.classList.add('page-home');
</script>

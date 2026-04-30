---
layout: page
title: Home
---

<div class="affl-dynamic-home">
  {% if site.league_logo %}
    <div style="text-align: center; margin-bottom: 20px;">
      <img src="{{ site.league_logo }}" alt="{{ site.league_name }}" style="max-width: 200px;">
    </div>
  {% endif %}
  {% if site.league_state == 'offseason' %}
    {% include home/offseason.html %}
  {% elsif site.league_state == 'predraft' %}
    {% include home/predraft.html %}
  {% elsif site.league_state == 'regular_season' %}
    {% include home/regular_season.html %}
  {% elsif site.league_state == 'playoffs' %}
    {% include home/playoffs.html %}
  {% else %}
    <h1>Welcome to {{ site.league_name }}</h1>
    <p>Official website for the AFFL hosted on Sleeper.</p>
  {% endif %}
</div>

<hr>

## League Navigation
- [About the League]({{ site.baseurl }}/about/)
- [Current & Past Standings]({{ site.baseurl }}/standings/)
- [League History]({{ site.baseurl }}/history/)
- [Official Rules]({{ site.baseurl }}/rules/)

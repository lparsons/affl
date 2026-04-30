---
layout: page
title: Standings
permalink: /standings/
---

# AFFL Standings

Choose a season to view standings:

<ul>
  {% for season in site.data.all_seasons %}
    <li>
      <a href="{{ site.baseurl }}/standings/{{ season.year }}/">{{ season.year }} Season</a>
      {% if season.year == site.current_season %} <strong>(Current)</strong> {% endif %}
    </li>
  {% endfor %}
</ul>

<hr>

{% assign latest_season = site.data.all_seasons | first %}
{% if latest_season %}
  <p>Looking for the latest? <a href="{{ site.baseurl }}/standings/{{ latest_season.year }}/">View {{ latest_season.year }} Standings</a></p>
{% endif %}

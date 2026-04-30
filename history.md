---
layout: page
title: History
permalink: /history/
---

# AFFL League History

## Past Champions

| Year | League Name | Champion Team | Manager |
|------|-------------|---------------|---------|
{% for season in site.data.all_seasons %}{% if season.status == 'complete' or season.year < site.current_season %}{% assign champ = season.standings | first %}| {{ season.year }} | {{ season.name }} | {{ champ.team_name }} | {{ champ.username }} |
{% endif %}{% endfor %}

## League Archive

Browse the full standings for every season in AFFL history:

<ul>
  {% for season in site.data.all_seasons %}
    <li><a href="{{ site.baseurl }}/standings/{{ season.year }}/">{{ season.year }} Season</a></li>
  {% endfor %}
</ul>

<hr>

## Commissioner Insights

> "The Art of Fantasy Football League has grown and thrived because of our passionate managers who treat fantasy football as a true art form. Our league's history is filled with unforgettable moments, fierce competitions, and a sense of community that brings us together every season."

- **AFFL Commissioner**

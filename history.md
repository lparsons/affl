---
layout: page
title: History
permalink: /history/
---

# AFFL League History

## League History & Archives

Browse past standings and celebrate our former champions.

| Year | Champion Team | Manager |
|------|---------------|---------|
{% for season in site.data.all_seasons %}{% assign champ = season.standings | first %}{% if champ.avatar %}{% assign avatar_url = "https://sleepercdn.com/avatars/thumbs/" | append: champ.avatar %}{% else %}{% assign avatar_url = "https://sleepercdn.com/images/v2/icons/player_default.webp" %}{% endif %}| [{{ season.year }}]({{ site.baseurl }}/standings/{{ season.year }}/) | {% if season.status == 'complete' or season.year < site.current_season %}<img src="{{ avatar_url }}" width="30" height="30" style="border-radius: 50%; vertical-align: middle; margin-right: 5px;"> {{ champ.team_name }}{% else %}*Season in Progress*{% endif %} | {% if season.status == 'complete' or season.year < site.current_season %}{{ champ.username }}{% else %}-{% endif %} |
{% endfor %}

<hr>

## Commissioner Insights

> "The Art of Fantasy Football League has grown and thrived because of our passionate managers who treat fantasy football as a true art form. Our league's history is filled with unforgettable moments, fierce competitions, and a sense of community that brings us together every season."

- **AFFL Commissioner**

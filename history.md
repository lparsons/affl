---
layout: page
title: History
permalink: /history/
---

<div class="dashboard-container">
  <div class="dashboard-header">
    <div>
      <h1 style="margin: 0;">League History</h1>
      <p style="margin: 5px 0 0; opacity: 0.8;">Hall of Champions & Archived Standings</p>
    </div>
  </div>

  <div class="dashboard-card">
    <table class="high-contrast-table">
      <thead>
        <tr>
          <th>Year</th>
          <th>Champion Team</th>
          <th>Manager</th>
        </tr>
      </thead>
      <tbody>
        {% for season in site.data.all_seasons %}
          {% assign champ = season.standings | first %}
          {% if champ.avatar %}
            {% assign avatar_url = "https://sleepercdn.com/avatars/thumbs/" | append: champ.avatar %}
          {% else %}
            {% assign avatar_url = "https://sleepercdn.com/images/v2/icons/player_default.webp" %}
          {% endif %}
          <tr>
            <td><a href="{{ site.baseurl }}/standings/#{{ season.year }}"><strong>{{ season.year }}</strong></a></td>
            <td>
              {% if season.status == 'complete' or season.year < site.current_season %}
                <div style="display: flex; align-items: center; gap: 10px;">
                  <img src="{{ avatar_url }}" width="30" height="30" style="border-radius: 50%;">
                  {{ champ.team_name }}
                </div>
              {% else %}
                <span style="opacity: 0.7; font-style: italic;">Season in Progress</span>
              {% endif %}
            </td>
            <td>
              {% if season.status == 'complete' or season.year < site.current_season %}
                {{ champ.username }}
              {% else %}
                -
              {% endif %}
            </td>
          </tr>
        {% endfor %}
      </tbody>
    </table>
  </div>

  <div class="dashboard-card" style="background: rgba(42, 122, 226, 0.05);">
    <h2>Commissioner's Note</h2>
    <blockquote style="margin: 0; padding: 0 20px; border-left: 4px solid var(--link-color); font-style: italic; opacity: 0.9;">
      "The Art of Fantasy Football League has grown and thrived because of our passionate managers who treat fantasy football as a true art form. Our league's history is filled with unforgettable moments, fierce competitions, and a sense of community."
    </blockquote>
    <p style="text-align: right; margin-top: 15px; font-weight: bold; opacity: 0.8;">— AFFL Commissioner</p>
  </div>
</div>

<script>
  // Add class to body for specific CSS targeting
  document.body.classList.add('page-history');
</script>

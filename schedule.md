---
layout: page
title: League Calendar & Schedule
permalink: /schedule/
---

# {{ site.current_season }} AFFL League Calendar & Schedule

Welcome to the official schedule and calendar for The Art of Fantasy Football League. Key dates are governed by the [AFFL Constitution & Rules]({{ site.baseurl }}/rules/) and synchronized with the active Sleeper season.

{% include date_warning_banner.html %}

## ⚡ Next Upcoming Milestone

{% include upcoming_event_banner.html %}

---

## 🗓️ Season Milestone Calendar

<div class="timeline-list">
  {% for event in site.data.league_calendar %}
    <div class="timeline-item {% if event.status == 'in_progress' %}status-in-progress{% elsif event == site.data.next_event %}status-next{% elsif event.status == 'past' %}status-past{% endif %}">
      <div class="timeline-icon">
        {{ event.icon }}
      </div>
      <div class="timeline-content">
        <div class="timeline-header">
          <div>
            <h3 class="timeline-title">
              {{ event.title }}
              {% if event.status == 'in_progress' %}
                <span style="font-size: 0.8em; color: #10b981; margin-left: 6px; font-weight: normal;">(In Progress)</span>
              {% endif %}
            </h3>
            <div class="timeline-date">
              📅 {{ event.formatted_date }}
            </div>
          </div>
          <div style="display: flex; gap: 6px; align-items: center; flex-wrap: wrap;">
            {% if event.status == 'in_progress' %}
              <span class="event-badge badge-live">🟢 In Progress (Day {{ event.days_in }})</span>
            {% elsif event.status == 'today' %}
              <span class="event-badge badge-next">Today</span>
            {% elsif event == site.data.next_event %}
              <span class="event-badge badge-next">Next Up ({{ event.days_away }}d)</span>
            {% elsif event.days_away > 0 %}
              <span class="event-badge badge-upcoming">In {{ event.days_away }} days</span>
            {% else %}
              <span class="event-badge badge-past">Completed</span>
            {% endif %}
            <span class="category-tag">{{ event.tag }}</span>
          </div>
        </div>
        <p class="timeline-description">
          {{ event.description }}
        </p>
        <div style="display: flex; gap: 12px; align-items: center;">
          {% if event.id == 'draft_day' and event.status == 'in_progress' %}
            <a href="https://sleeper.com/draft/nfl/{{ site.current_draft_id }}?is_active=true" target="_blank" class="btn" style="padding: 4px 12px; font-size: 0.85em; background: #10b981; color: #fff !important;">Enter Draft Room ↗</a>
          {% endif %}
          <a href="{{ site.baseurl }}{{ event.rule_ref }}" style="font-size: 0.85em; font-weight: bold; text-decoration: underline;">View Constitution Rule &rarr;</a>
        </div>
      </div>
    </div>
  {% endfor %}
</div>

---

## 🏈 In-Season Weekly Schedule & Matchups

* **Regular Season:** Weeks 1 through 14 (14 head-to-head regular season matchups).
* **Playoffs:** Weeks 15 through 17 (3-round tournament: Wild Card, Semifinals, and AFFL Super Bowl / Toilet Bowl Final).

<div style="margin: 20px 0; display: flex; gap: 15px; flex-wrap: wrap;">
  <a href="https://sleeper.com/leagues/{{ site.current_league_id }}/matchup" target="_blank" class="btn">View Live Matchups on Sleeper</a>
  <a href="https://sleeper.com/leagues/{{ site.current_league_id }}/playoffs" target="_blank" class="btn">View Playoff Bracket on Sleeper</a>
</div>

---

## ⏰ Recurring In-Season Deadlines

| Category | Deadline | Policy Summary |
|:---|:---|:---|
| **Waiver Wire Claims** | **Wednesday Morning** *(automated)* | Unclaimed players become free agents after claims process. |
| **Free Agent Add/Drop** | **Individual Game Kickoff** | Unlocked players may be added/dropped until their scheduled kickoff. |
| **Lineup Locks** | **Individual Game Kickoff** | Starters and bench players lock automatically once their game begins. |
| **Trade Deadline** | **Conclusion of Week 13** | In-season trades lock after Week 13 games conclude. |
| **Playoff Free Agency Lock** | **Start of Week 15** | Free agency locks for the season before the first playoff kickoff. |

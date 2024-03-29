#!/usr/bin/env python3

# metadata
# <xbar.title>MS Teams Next Meetings</xbar.title>
# <xbar.version>v0.1.2</xbar.version>
# <xbar.author>Alexander Lais</xbar.author>
# <xbar.author.github>peanball</xbar.author.github>
# <xbar.desc>Shows upcoming MS Teams meetings and links them to the MS Teams Desktop client directly.</xbar.desc>
# <xbar.abouturl>https://github.com/peanball/teams-swiftbar/README.md<xbar.abouturl>
# <xbar.image>https://raw.githubusercontent.com/peanball/teams-swiftbar/main/screenshot.png</xbar.image>
# <xbar.dependencies>python3, icalBuddy(fixed)</xbar.dependencies>
# <swiftbar.runInBash>true</swiftbar.runInBash>

from datetime import datetime, date, timezone, timedelta
import os

import re
from dateutil import parser

from urllib.parse import unquote

BULLET = "__BULLET__"

LOCAL_TIMEZONE = datetime.now(timezone.utc).astimezone().tzinfo
now = datetime.now(tz=LOCAL_TIMEZONE)

cmd = (
    f"icalBuddy -b '{BULLET}' -nnr "
    ' -tf "%Y-%m-%dT%H:%M:%S.000%z" -nc -iep "title,datetime,notes"  -ps "|\t|" eventsToday '
    '| tr "\r" " "'
)

teams_link = r"(?: |<|&lt;)https://teams.microsoft.com(.*?)(?:>|&gt;| )"

teams_meetings = []

with os.popen(cmd) as result:
    entries = [entry.strip() for entry in result.readlines()]

    for entry in entries:
        split = entry.split("\t")
        link = None

        if len(split) < 3:
            continue

        name, notes, time = split
        name = name.replace(BULLET, "")
        startDate, endDate = re.sub(r"^.* at", "", time).split(" - ")
        end = now
        try:
            end = parser.parse(endDate)
            if end < now:
                continue
        except parser.ParserError as e:
            if endDate == "...":
                end = datetime.combine(date.today() + timedelta(days=1), datetime.min.time())

        start = parser.parse(startDate)

        links = re.findall(teams_link, notes)
        if links:
            link = f"msteams:{links[0]}"

            teams_meetings.append(
                [
                    name,
                    start,
                    end,
                    link,
                ]
            )

if not teams_meetings:
    exit(0)


def format_duration(seconds):
    words = ["y", "d", "h", "m", "s"]

    if not seconds:
        return "now"
    else:
        m, s = divmod(seconds, 60)
        h, m = divmod(m, 60)
        d, h = divmod(h, 24)
        y, d = divmod(d, 365)

        time = [y, d, h, m, s]

        duration = []

        for x, i in enumerate(time):
            if i > 0:
                duration.append(f"{int(i)}{words[x]}")

        return "".join(duration)


running_meeting = [
    m for m in teams_meetings if m[1] <= now and m[2] > now
]

# print("running:",running_meeting)

# time in minutes when a 'countdown' is shown in the item's main text
upcoming_time = 15
# time in minutes when a 'countdown' is shown with a link to the meeting in the item's main text
pending_time = 8

upcoming_meeting = [
    m
    for m in teams_meetings
    if m[1] > now
       and (m[1] - now).total_seconds() > 0
       and (m[1] - now) < timedelta(minutes=upcoming_time)
       and (m[1] - now) > timedelta(minutes=pending_time)
]

# print("upcoming:",upcoming_meeting)

pending_meeting = [
    m
    for m in teams_meetings
    if m[1] > now
       and (m[1] - now).total_seconds() > 0
       and (m[1] - now) < timedelta(minutes=pending_time)
]


# print("pending:",pending_meeting)


def by_start(m):
    return m[1]


if pending_meeting:
    (name, start, end, link) = sorted(pending_meeting, key=by_start)[0]
    timespan = (start - now).total_seconds() - (start - now).total_seconds() % 60
    time_to_meeting = format_duration(timespan)
    print(
        f":rectangle.3.group.bubble.left.fill: {name} in {time_to_meeting} | sfcolor=#CC0000,#FF3300 href={link}"
    )
elif running_meeting:
    (name, start, end, link) = sorted(running_meeting, key=by_start)[0]
    print(f":rectangle.3.group.bubble.left.fill: {name} | href={link}")
elif upcoming_meeting:
    (name, start, end, link) = sorted(upcoming_meeting, key=by_start)[0]
    timespan = (start - now).total_seconds() - (start - now).total_seconds() % 60
    time_to_meeting = format_duration(timespan)
    print(f":rectangle.3.group.bubble.left.fill: {name} in {time_to_meeting}")
else:
    print(":rectangle.3.group.bubble.left:")
print("---")

for (name, start, end, link) in sorted(teams_meetings, key=by_start):
    starttime = start.strftime("%H:%M")
    endtime = end.strftime("%H:%M")
    duration = format_duration((end - start).total_seconds())
    href = ""
    if link:
        href = f" | href={link}"
    print(f"{name.strip()} - {starttime} ({duration}){href}")

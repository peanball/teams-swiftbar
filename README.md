# MS Teams Meetings Launcher in SwiftBar

This plugin checks your calendar for upcoming MS Teams meetings and links them with direct links to the MS Teams desktop client. No more weird redirects through the browser, just open the meeting right away.

## Features

* Finds calendar entries for the current day that contain links to https://teams.microsoft.com and turns them to `msteams:` links that are opened by the MS Teams Desktop client right away
* Indicates an upcoming meeting 15 min before it starts with the name in the toolbar
* Shows you the name of the currently running meeting
* Warns you about a meeting that is about to start and turns the item to a direct link for this meeting
* Shows you the the warning about the next meeting, even if there is a meeting running (back to back)

## Prerequisites

1. SwiftBar. This will likely also work with XBar but I have not tried.
2. `icalBuddy`.  
    Usually this can be installed via `brew install ical-buddy`, but the version there is not working correctly in SwiftBar.
    See below in Troubleshooting.

## Troubleshooting

* SwiftBar needs to have Calendar permissions. The current version 1.4.3 (and 1.4.4 beta) were not asking for permission. Version 1.2.1 did ask for permission.
* The version currently (2022-05-25) installed via Homebrew has a bug that will not ask for Calendar access and will not show any results. A pre-built version [in the KeyboardMaestro Forum](https://forum.keyboardmaestro.com/t/icalbuddy-doesnt-work-within-keyboard-maestro-mojave-calendar-permissions/15446/6) works fine. Install at your own risk. There is hope that the upstream maintainer of the Homebrew release will include the patch soon and I can remove this section.

# JS8Call Plus

JS8Call Plus is JS8Call 3.0.3 with a better decoder: js8core-plus.
It looks and works like JS8Call. Only the decoder is different.

JS8Call Plus is not the official JS8Call and is not supported by the
JS8Call-improved team.

## Why

On live JS8 traffic, js8core-plus decodes 17.0% more transmissions than
JS8Call 3.0.3.

Live test, public KiwiSDR receivers on 7.078 MHz, frames decoded from
2026-11-22 22:16 UTC to 2026-11-25 03:15 UTC:

| Speed  | JS8Call 3.0.3 (bug fixed) | JS8Call Plus | More   |
|--------|--------------------------:|-------------:|-------:|
| Normal | 11,931                    | 13,883       | +16.4% |
| Fast   | 1,705                     | 2,053        | +20.4% |
| Turbo  | 189                       | 210          | +11.1% |
| Slow   | 148                       | 204          | +37.8% |
| All    | 13,973                    | 16,350       | +17.0% |

The 3.0.3 column has the JS8Call-improved team's fix for a 3.0.3 bug that
misses stations overlapping a stronger one. The fix is in their
development code, not in a release yet.

Live scoreboard: https://va3oso.ca/js8core/livetest/

## What's different from JS8Call 3.0.3

- The js8core-plus decoder.
- Settings > General > Behavior > Enable Deep Decoding: finds about 2%
  more messages, with more errors, and takes twice as long to decode.
  Off unless ticked.
- Its own settings folder, so it doesn't change JS8Call's settings or
  Message Inbox. Both can be installed side by side.
- Your status message sends VERSION JS8CALL-PLUS 1.0.0.

## Download

From the Releases page:

- Windows: JS8Call-Plus-1.0.0-installer.exe
- Mac, Apple Silicon (M1 and later) and Intel: .dmg
- Linux PC and Raspberry Pi (64-bit Raspberry Pi OS): AppImage

The files are not signed yet:

- Windows shows "Windows protected your PC": click More info, then
  Run anyway.
- Mac blocks the first open: go to System Settings > Privacy & Security
  and click Open Anyway.

## User guide

JS8Call Plus works like JS8Call, so JS8Call's user guide applies:
https://js8call-improved.github.io/JS8Call-improved/d6/d14/md_docs_2user__guide_2JS8Call__User__Guide.html

## Credits

- Based on JS8Call 3.0.3 by the JS8Call-improved team: Chris AC9KH,
  Allan W6BAZ, Wyatt KJ4CTD, Joe K0OG, Andreas DJ3EI, Rob K4RWR,
  Jordan KN4CRD. https://github.com/JS8Call-improved/JS8Call-improved
- JS8Call was created by Jordan Sherer, KN4CRD.
- js8core-plus decoder: Kelly-Shane Fuller, VA3OSO, MIT licence.
  Based on JS8Core by the JS8Call-improved team.
- JS8Call is a derivative of WSJT-X (K1JT and the WSJT-X team). It is not
  supported by or endorsed by the WSJT-X development group.

## Licence

GPLv3, the same as JS8Call. See LICENSE. All copyrights remain with
their original holders.

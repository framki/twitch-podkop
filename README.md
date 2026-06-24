# twitch-podkop

Twitch livestream ad bypass rule-set for [Podkop](https://podkop.net) (OpenWrt + sing-box).
Routes only Twitch's ad-signaling domains through a tunnel exiting in an ad-free country.
Video segments are not proxied — overhead is ~20 Kb/s.

## How it works

Twitch uses server-side ad insertion (SSAI): ads are determined by the playlist/manifest
request IP, not client-side. Route those requests through an ad-free country exit and
Twitch returns an ad-free playlist. Replicates [TTV LOL PRO](https://github.com/younesaassila/ttv-lol-pro) at the router level.

## Domains

Source: [TTV LOL PRO wiki](https://wiki.cdn-perfprod.com/must-read/how-it-works.md)

| Domain | Role |
|---|---|
| `usher.ttvnw.net` | Stream lookup |
| `gql.twitch.tv` | GraphQL (ad decisions) |
| `*.playlist.ttvnw.net` | Playlist |
| `*.playlist.live-video.net` | Playlist (alt CDN) |
| `video-weaver.*.hls.ttvnw.net` | SSAI manifest — the critical one |

`video-weaver` requires a regex to avoid matching `video-edge-*` (actual video segments).
`passport.twitch.tv` and `www.twitch.tv` are intentionally excluded — not needed for ad
bypass, and routing auth through a third-party exit is a security risk.

## Podkop setup

In Podkop, create a section (e.g. `twitch`), set your tunnel, and add to **Remote Domains Lists**:

```
https://raw.githubusercontent.com/framki/twitch-podkop/main/twitch-ad-bypass.srs
```

The tunnel exit must be in a currently ad-free country (check the TTV LOL PRO community
list — it shifts over time) and must have outbound IPv4.

## Updating

Edit `twitch-ad-bypass.json`, then:

```sh
./update.sh
```

Downloads sing-box 1.12.25 on first run (cached), recompiles, verifies round-trip, commits and pushes.

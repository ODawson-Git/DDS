# How to contribute to supported resolutions

In `DDS.ahk` at around line `36` we have

```autohotkey
Resolutions := {
    ...,
    1920x1080: {Phase:{x:1853,y:63}, Hero:{x:44,y:82}, Toggle:{x:1645,y:837}, Repair{x:973, y:531},
    ...
}
```

For this example we will want to add a resolution of size `WIDTH` by `HEIGHT`, before we can add it in to the script we need to get some measurements. 

All of the measurements in the table are assuming that the top left pixel of the game is `(0,0)`. To get the coordinates I use [ShareX](https://getsharex.com/) however AutoHotKey has [WindowSpy](https://amourspirit.github.io/AutoHotkey-Snippit/WindowSpy.html) built in also, but I would recommend ShareX.

We now need to get the coordinates of `Phase`, `Hero`, `Toggle`, `Repair`

- `Phase` coordinates take the screen position around [here](https://i.imgur.com/REAVG8F.png) `PHASEX`, `PHASEY`
- `Hero` coordinates take the screen position around [here](https://i.imgur.com/TqmQVnp.png) `HEROX`, `HEROY`
- `Toggle` coordinates are taken at the top right most pixel not in the skill border [here](https://i.imgur.com/8jmYSO8.png) `TOGGLEX`, `TOGGLEY`
- `Repair` coordinates take screen position [anywhere on the wrench with red pixels](https://i.imgur.com/YtWyZQi.png) `REPAIRX`, `REPAIRY`

Now that we have our coordinates we add them to the script along with our resolution

```autohotkey
Resolutions := {
    ...,
    1920x1080: {Phase:{x:1853,y:63}, Hero:{x:44,y:82}, Toggle:{x:1645,y:837}, Repair{x:973, y:531},
    WIDTHxHEIGHT: {Phase:{x:PHASEX,y:PHASEY}, Hero:{x:HEROX,y:HEROY}, Toggle:{x:TOGGLEX,y:TOGGLEY}, Repair{x:REPAIRX, y:REPAIRY},
    ...
}
```

Now we need to reopen the script and enable debug (F8) to see if it is reading the correct values
![](https://i.imgur.com/XuW87H7.png)

<sub>Some values only appear when activated, e.g. repair. It is normal for the debug window to flicker as it is being updated very fast</sub>

Along the debug window we have what the game is returning our coordinate as `monk`, then the corresponding RGB value `299 102 32` and then the position it is reading from `(44, 82)` and then the time it was last sampled `17232734`

We now need to check that it returns everything correct for all heroes etc and if it does please DM me Wurzle#7136 on discord and I'll add it to the script for everyone else

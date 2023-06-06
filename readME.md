![](https://i.imgur.com/oZ3gHmt.png)

# DDS
Utility AutoHotKey script for Dungeon Defenders Awakened.  


## Usage
Requires [AutoHotKey v2](https://www.autohotkey.com/download/ahk-v2.exe) to run. Simply open `DDS.ahk`

The script reads colors on screen to know current game phase and hero being played so only some resolutions are supported

**Current supported resolutions**
- 3072x1920
- 3440x1440
- 2560x1440
- 1920x1080
- 1360x768
- 1280x720
- 960x540

<sub>If you would like to contribute to the supported resolutions follow this [guide](https://github.com/ODawson-Git/DDS/blob/main/resolutionContribution.md)</sub>

## Keybinds

<sub>Few abilities work in blind mode i.e. no DDA visible. </sub>

---

**Ctrl+Del**: Kills the script 

**Ctrl+Alt+R**: Resizes DDA to 960x540 (change on line ~320)

**Ctrl+Alt+T**: Ends map, takes screenshot and shuts down PC on summary phase

**F7**: Enable debug 

**F8**: Auto repair 

**Ctrl+F8** Enable mana dump

**F9**: Auto G (not wave 1) 

**Ctrl+F9**: Toggles between force G and solo G 

| **Heroes / Keybinds** 	| **F10**  \| Hero Boost  	| **CTRL+F10**  \| Hero Skill 	| **F11**  \| Tower Boost 	| **CTRL+RMB**  \| Auto Fire 	|
|-----------------------	|-------------------------	|-----------------------------	|-------------------------	|----------------------------	|
| **Monk**              	| Hero Boost              	| -                           	| Tower Boost             	| RMB                        	|
| **Apprentice**        	| -                       	| Mana bomb (no rune)         	| Hero Boost + RMB        	| LMB                        	|
| **Squire**            	| Blood Boil              	| Circular Slice              	| -                       	| LMB                        	|
| **Huntress**          	| Adrenaline Rush         	| Phoenix Shot                	| -                       	| LMB                        	|
| **EV**                	| -                       	| Decoy                       	| -                       	| LMB                        	|
| **Rouge**             	| Umbral Form and Carnage 	| -                           	| -                       	| RMB                        	|
| **Warden**            	| Wrath                   	| -                           	| Wrath                   	| LMB                        	|
| **Summoner**          	| Pet Boost               	| -                           	| Flash Heal              	| Repair Mouse Mode          	|
| **Guardian**          	| Divine Protection       	| Divine Judgement            	| -                       	| LMB                        	|

<sub>Currently, `Auto repair mouse mode` only works on Windows scaling 100%</sub>

<sub>Umbral and Carnage change line ~94 delay to the greatest cooldown of the two</sub>


## Known issues
- When enabling the minimap, due to the blur effect, some toggles may be miss recorded and bugs may happen.

- Auto repair mouse mode only works for Windows scaling 100% due to DDA bug"?" with wrench size
![](https://i.imgur.com/fmfjFQL.jpeg)

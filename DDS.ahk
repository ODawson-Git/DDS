#SingleInstance Force
#Requires AutoHotkey v2.0-beta

v := 240208 ;YYMMDD
DDAexe := "ahk_exe DDS-Win64-Shipping.exe" ; You can use Window Spy to see the exe name
DisableBlind := false ; Set to true if you want to disable blind mode (some games have issues with it)

objindexget(obj,key) { 
    if obj.HasOwnProp(key) 
        return obj.%key% 
    else 
        return false 
}
objindexset(obj,value,key) {
    if obj.HasOwnProp(key)
        obj.%key% := value
	else
        obj.DefineProp(key,{Value:value})
}
Object.Prototype.DefineProp("__Item", {Get: objindexget, Set: objindexset})
CoordMode("Pixel", "Screen")
CoordMode("Mouse", "Screen")

State := {  ToggleAutoG : 0,
            ToggleAutoAttack : false,
            ToggleHeroBuff : false,
            ToggleHeroSkill : false,
            ToggleTowerBuff : false,
            ToggleRepair : false,
            ToggleMouseRepair : false,
            ToggleDebug : false,
            ToggleManaDump : false,
	        ToggleSummaryShutdown:  false,
            PostWarmup : false,
            PostMapover : 0,
            NextShutdown : 0,
            NextF : 0,
            NextC : 0,
            NextM : 0,
            NextG : 0,
            NextTowerPlace: 0,
            NextInput : 0,
            lastphase : "0"}

Resolutions := {
    3072x1920:  {   Phase:{x:2962,y:113}, 
                    Hero:{x:65,y:149}, 
                    ToggleC:{x:2597,y:1491}, 
                    ToggleF:{x:2749, y:1491}, 
                    Repair:{x:1560, y:945}, 
                    MouseRepairOffset:{x:-3, y:-3}
                },
    3440x1440:  {   Phase:{x:3332,y:88}, 
                    Hero:{x:41,y:113}, 
                    ToggleC:{x:3030,y:1117}, 
                    ToggleF:{x:3145, y:1117}, 
                    Repair:{x:1730, y:702}, 
                    MouseRepairOffset:{x:-3, y:-3}
                }, 
    2560x1440:  {   Phase:{x:2475,y:74}, 
                    Hero:{x:48,y:120}, 
                    ToggleC:{x:2191,y:1201}, 
                    ToggleF:{x:2306, y:1201}, 
                    Repair:{x:23, y:687}, 
                    MouseRepairOffset:{x:-2, y:-2}
                },
    1920x1080:  {   Phase:{x:1853,y:63}, 
                    Hero:{x:36,y:90}, 
                    ToggleC:{x:1644,y:901}, 
                    ToggleF:{x:1729, y:901}, 
                    Repair:{x:973, y:531}, 
                    MouseRepairOffset:{x:-1, y:-1}
                },
    1360x768:   {   Phase:{x:1313,y:39}, 
                    Hero:{x:26,y:61}, 
                    ToggleC:{x:1163,y:596}, 
                    ToggleF:{x:1224, y:596},
                    Repair:{x:689, y:378}, 
                    MouseRepairOffset:{x:-1, y:-1}
                },
    1280x720:   {   Phase:{x:1235,y:40}, 
                    Hero:{x:24,y:57}, 
                    ToggleC:{x:1096,y:558}, 
                    ToggleF:{x:1153, y:558},
                    Repair:{x:649, y:355}, 
                    MouseRepairOffset:{x:-1, y:-1}
                },
    960x540:    {   Phase:{x:927,y:30}, 
                    Hero:{x:18,y:43}, 
                    ToggleC:{x:822,y:419}, 
                    ToggleF:{x:842,y:419}, 
                    Repair:{x:487, y:266}, 
                    MouseRepairOffset:{x:-1, y:-1}
                }
}

PhaseColors := {
    mapover:    {R: 0,          G: 77,          B: 119,     Rm: 7  ,         Gm: 55,        Bm: 94  }, 
    warmup:     {R: 162,        G: 117,         B: 0,       Rm: 153,         Gm: 112,        Bm: 16  }, 
    build:      {R: 75,         G: 124,         B: 0,       Rm: 57 ,         Gm: 85,        Bm: 16  }, 
    combat:     {R: 127,        G: 25,          B: 39,      Rm: 90 ,         Gm: 20,        Bm: 42  }, 
    tavern:     {R: 188,        G: 101,         B: 0,       Rm: 115,         Gm: 62,        Bm: 16  }, 
    boss:       {R: 133,        G: 0,           B: 115,     Rm: 112  ,       Gm: 24,        Bm: 109   },
    loading:    {R: 154,        G: 36,          B: 0,       Rm: 154,         Gm: 36,        Bm: 0   },
    inventory:  {R: 106,        G: 106,         B: 106,     Rm: 106,         Gm: 106,       Bm: 106 }
}

ToggleColors := {
    on1:       {R: 0,        G: 240,         B: 240,     Rm: 15,     Gm: 100,     Bm: 130 }, 
    on2:       {R: 0,        G: 220,         B: 220,     Rm: 25,     Gm: 65,     Bm: 98  }, 
    0:        {R: 13,        G: 136,           B: 124,      Rm: 23,     Gm: 78,     Bm: 89 },
}

RepairColors := {
    redwrench:      {R: 255,    G: 0,       B: 0,     Rm: 255,      Gm: 0,     Bm: 0 },
    greenwrench:    {R: 0,      G: 255,     B: 0,     Rm: 0,        Gm: 255,   Bm: 0 }
}

HeroColors := {
    apprentice:  {R: 0,         G: 131,         B: 204,   Rm: 30,      Gm: 70,     Bm: 104}, 
    monk:        {R: 229,       G: 102,         B: 32,    Rm: 111,     Gm: 61,     Bm: 50 }, 
    squire:      {R: 165,       G: 17,          B: 17,    Rm: 86,      Gm: 34,     Bm: 45 }, 
    huntress:    {R: 0,         G: 127,         B: 57,    Rm: 33,      Gm: 69,     Bm: 57 }, 
    ev:          {R: 122,       G: 29,          B: 185,   Rm: 73,      Gm: 38,     Bm: 98}, 
    warden:      {R: 17,        G: 88,          B: 77,    Rm: 40,      Gm: 56,     Bm: 64 }, 
    rogue:       {R: 86,        G: 4,           B: 54,    Rm: 62,      Gm: 30,     Bm: 56 }, 
    summoner:    {R: 54,        G: 52,          B: 85,    Rm: 51,      Gm: 45,     Bm: 66 },
    guardian:    {R: 252,       G: 151,         B: 0,     Rm: 107,     Gm: 69,     Bm: 33 },
}

HeroAbilities := {
    apprentice: {   A: "LEFT",
                    C: {Type: "TowerBuff", AnimT: 1500, Recast: "M2ToggleC", Cooldown: 5500, M2AnimT: 1500, M2Recast: 7000},
                    F: {Type: "HeroSkill", AnimT: 1250, Recast: "ToggleF"}
                }, 
    monk:       {   A: "RIGHT",
                    F: {Type: "TowerBuff", AnimT: 500, Recast: "TimerToggleF", Cooldown: 19000},
                    C: {Type: "HeroBuff", AnimT: 500, Recast: "ToggleC"}
                }, 
    squire:     {   A: "LEFT",
                    F: {Type: "HeroSkill", AnimT: 1000, Recast: "ToggleF"},
                    C: {Type: "HeroBuff", AnimT: 500, Recast: "ToggleC"}
                },
    huntress:   {   A: "LEFT",
                    F: {Type: "HeroSkill", AnimT: 1000, Recast: "ToggleF"},     
                    C: {Type: "HeroBuff", AnimT: 500, Recast: "ToggleC"}
                }, 
    ev:         {   A: "LEFT",
                    F: {Type: "HeroSkill", AnimT: 1000, Recast: "ToggleF"},
                },    
    warden:     {   A: "LEFT",
                    C: {Type: "Both", AnimT: 1000, Recast: "ToggleC"}
                }, 
    rogue:      {   A: "BOTHLR", ; Send Right then Left
                    ATOWER: {Type: "AutoAttack", Numbers: [1, 2, 3], Delay: 0},
                    TOWER: {Type: "HeroSkill", Numbers: [4, 5], Delay: 15000}
                },
    summoner:   {   A: "Repair",   
                    F: {Type: "TowerBuff", AnimT: 2000, Recast: "TimerToggleF", Cooldown: 5100},
                    C: {Type: "HeroBuff", AnimT: 500, Recast: "ToggleC"}
                },
    guardian:   {   A: "LEFT",
                    F: {Type: "HeroSkill", AnimT: 1000, Recast: "ToggleF"},
                    C: {Type: "HeroBuff", AnimT: 500, Recast: "ToggleC"},
                    
                }
}

global WindowCoords := {init: 0}

GetWindowCoords()
{
	if WinExist(DDAexe){
		WinGetClientPos(&Xo, &Yo, &Wo, &Ho, DDAexe)
        global WindowCoords := {init: 1, x: Xo, y: Yo, w: Wo, h: Ho}

        if Resolutions[WindowCoords.w "x" WindowCoords.h] {
            global Res := WindowCoords.w "x" WindowCoords.h
        }
        else{
            global WindowCoords := {init: 0, x: Xo, y: Yo, w: Wo, h: Ho}
            Show("Resolution not supported : ", "information",  "")
        }    
	}
    else
    {
        global WindowCoords := {init: 0, x: 0, y: 0, w: 0, h: 0}
    }
}

WindowOffset(offset){
    return {x: WindowCoords.x + offset.x, y: WindowCoords.y + offset.y}
}

GetMousePos(offset:= 0){ ; only works on Windows Scaling 100%
    MouseGetPos(&MouseX, &MouseY)
    return {x: MouseX + offset.x, y: MouseY + offset.y}
}

global PixelValues := Map()

CheckColorFuzzy(Varname, Coord, Table, Threshold := 16581375) {
	Color := PixelGetColor(Coord.x, Coord.y)
	R := (Color & 0xFF0000) >> 16
	G := (Color & 0xFF00) >> 8
	B := (Color & 0xFF)
	Error := Threshold
	Ret := "0"
	for k, v in Table.OwnProps()
    {
        tError := Abs(R-v.R)*Abs(R-v.R) + Abs(G-v.G)*Abs(G-v.G) + Abs(B-v.B)*Abs(B-v.B)
        if tError < Error {
            Error := tError
            Ret := k
        }
        mError := Abs(R-v.Rm)*Abs(R-v.Rm) + Abs(G-v.Gm)*Abs(G-v.Gm) + Abs(B-v.Bm)*Abs(B-v.Bm)
        if mError < Error {
            Error := mError
            Ret := k
        }
    }
    PixelValues[Varname] := {s: Ret, r: R, g: G, b: B, x: Coord.x, y: Coord.y, u: A_TickCount, c: Color, e: "0"}
}

WinGetAtCoords(coords) {
    if DisableBlind { 
        return DDAexe
    }

    try {
        ParentWinID := DllCall("WindowFromPoint", "UInt64", (coords.x & 0xFFFFFFFF) | (coords.y << 32), "Ptr")
        Name := WinGetProcessName(ParentWinID)
    } catch {
        return "ahk_exe ERROR GETTING HANDLE"
    }
    return "ahk_exe " Name
}

GUIColors := {
	backcolor:      "C25292E", 
	information:    "C60D9EF", 
    ON:             "C7CFC00", 
	OFF:            "CDC143C"
}

ShowDebug(){
    if State.ToggleDebug {
        ShowGUI := Gui()
        ShowGUI.Opt("+AlwaysOnTop -Caption +ToolWindow -DPIScale")
        ShowGUI.SetFont("s11")
        ShowGUI.BackColor := GUIColors.backcolor
        for k, v in PixelValues {
            ShowGUI.Add("Text", "xm " GUIColors.information, k "  -  " v.s "      " v.r "  " v.g "  " v.b)
            ShowGUI.Add("Progress", "W20 H20 x+m c" v.c " Background" GUIColors.backcolor , 100)
            ShowGUI.Add("Text", "x+m " GUIColors.information, "(" Round(v.x) ", " Round(v.y) ")   |   " v.u)
            if v.e {
                ShowGUI.Add("Text", "x+m " GUIColors.information, "- " v.e)
            }
        }
        for k, v in State.OwnProps() {
            cc := v ? GUIColors.ON : GUIColors.OFF ; This apparently stops args in add from being evaluated, so it's here
            ShowGUI.Add("Text", cc " xm h10", k "  -  " v)
        }
        ShowGUI.Show("y" A_ScreenHeight " NoActivate") ; Show out of viewing area to get dimensions
        ShowGUI.GetPos(, , &GWidth, &GHeight) ; GetPos only works when GUI active
        ShowGUI.Move(WindowCoords.x, WindowCoords.y + WindowCoords.h*0.5 - GHeight*0.5)
        Cleanup(){
            ShowGUI.Destroy() 
        }
        SetTimer(Cleanup,-100)
    }
}

Show(text, state, text2){
    ShowGUI := Gui()
    ShowGUI.Opt("+AlwaysOnTop -Caption +ToolWindow -DPIScale")
    ShowGUI.SetFont("s11")
    ShowGUI.BackColor := GUIColors.backcolor
    ShowGUI.Add("Text", GUIColors.%state%, text state text2)
    ShowGUI.Show(" y -100" " NoActivate") ; Show out of viewing area to get dimensions
    ShowGUI.GetPos(, , &GWidth, &GHeight) ; GetPos only works when GUI active
    ShowGUI.Move(WindowCoords.x + WindowCoords.w*0.5 - GWidth*0.5, WindowCoords.y + WindowCoords.h*0.5 - GHeight*0.5)
    Cleanup(){
        ShowGUI.Destroy() 
    }
    SetTimer(Cleanup,-1200)
}

Update(){
    if(DllCall("Wininet.dll\InternetGetConnectedState", "Str", "0x20", "Int", 0) == 1){ ;If local system online
	    hObject := ComObject("WinHttp.WinHttpRequest.5.1") ;Create the Object
	    hObject.Open("GET", "https://raw.githubusercontent.com/ODawson-Git/DDS/main/lastVersionNumber?t=") ;Open communication
	    hObject.Send() ;Send the "get" request
	    newVerSplit:=StrSplit(hObject.ResponseText, ":")
	    if(newVerSplit[1]>v){
            ;make gui
            UpdateGUI := Gui("-Theme")
            UpdateGUI.Opt("+AlwaysOnTop -Caption +ToolWindow")
            UpdateGUI.SetFont("s11")
            UpdateGUI.BackColor := GUIColors.backcolor
            UpdateGUI.Add("Text", GUIColors.information, "New feature(s) added:")
            changelog:= StrSplit(newVerSplit[2], "|")[1]
            UpdateGUI.Add("Text", GUIColors.information, changelog)
            UpdateGUI.Add("Text", GUIColors.information, "Would you like to update?")
            UpdateGUI.Add("Button", GUIColors.information " Background" SubStr(GUIColors.backcolor, 2, 6) " " , "Yes").OnEvent("Click", Install)
            UpdateGUI.Add("Button", GUIColors.information " x+m Background" SubStr(GUIColors.backcolor, 2, 6) , "No").OnEvent("Click", Cleanup)
            UpdateGUI.Show("xCenter yCenter")

            ; button functionality
            Install(*){
                Download("https://raw.githubusercontent.com/ODawson-Git/DDS/main/DDS.ahk?t=%", A_ScriptName)
                UpdateGUI.Destroy()
                Reload
            }
            Cleanup(*){
                UpdateGUI.Destroy()
            }
        }
    }
}

ShutdownTimer(){ ; 0 = not started, 1 = started, 2 = cancelled
    if (State.PostMapover == 0) {
        ShutdownGUI := Gui("-Theme")
        ShutdownGUI.Opt("+AlwaysOnTop -Caption +ToolWindow -DPIScale")
        ShutdownGUI.SetFont("s11")
        ShutdownGUI.BackColor := GUIColors.backcolor
        ShutdownGUI.Add("Button", GUIColors.information " Background" SubStr(GUIColors.backcolor, 2, 6) " " , "Cancel").OnEvent("Click", Cancel)
        ShutdownGUI.Show(" y -100") ; Show out of viewing area to get dimensions
        ShutdownGUI.GetPos(, , &GWidth, &GHeight) ; GetPos only works when GUI active
        ShutdownGUI.Move(WindowCoords.x + WindowCoords.w - GWidth, WindowCoords.y + WindowCoords.h*0.5 - GHeight*0.5)
        State.NextShutdown := A_TickCount + 60000
        Screenshot()
        SetTimer(Screenshot, -5000)
        State.PostMapover := 1
    }

    if (A_TickCount > State.NextShutdown && State.PostMapover == 1) {
        Shutdown 1
    }

    Cancel(*){
        State.PostMapover := 2
        ShutdownGUI.Destroy()
    }

    Screenshot(*){
        ControlSend("{Blind}{F12}", , DDAexe)
    }
}

UpdatePixelValues(key, windowOffset, blindString, colors, threshold) {
    global PixelValues

    PixelValues[key].e := WinGetAtCoords(windowOffset)
    if PixelValues[key].s != blindString {
        Show("Blind " key " : ", "ON", "")
        PixelValues[key].s := blindString
    }
}

Resize(w, h){ ; resizes win
    WinMove ,, w, h, DDAexe
    WinGetClientPos(,, &Wo, &Ho, DDAexe)
    WinMove ,, 2*w - Wo, 2*h - Ho, DDAexe
}

G(ignorestate := False){
    if (State.ToggleAutoG || ignorestate) && A_TickCount > State.NextG {
        if State.ToggleAutoG == 1 {
            State.NextG := A_TickCount + 1000
            ControlSend("{Blind}{g down}", , DDAexe)
            GUp(){
                ControlSend("{Blind}{g up}", , DDAexe)
            }
            SetTimer(GUp,-420)
        }
        else{
            State.NextG := A_TickCount + 2200
            ControlSend("{Blind}{ctrl down}", , DDAexe)
            GDown(){
                ControlSend("{Blind}{g down}", , DDAexe)
            }
            SetTimer(GDown,-100)
            GfUp(){
                ControlSend("{Blind}{g up}{ctrl up}", , DDAexe)
            }
            SetTimer(GfUp,-1780)
        }
    }
}

M(){
    if State.ToggleManaDump && A_TickCount > State.NextM
    {
        State.NextM := A_TickCount + 1000
        ControlSend("{Blind}{m down}", , DDAexe)
        ManaUp(){
            ControlSend("{Blind}{m up}", , DDAexe)
        }
        SetTimer(ManaUp,-550)
    }
}

PlaceTowers(hero){
    if A_TickCount > State.NextTowerPlace
    {
        State.NextTowerPlace := A_TickCount + HeroAbilities[hero]["TOWER"].Delay + 2500
        State.NextG := A_TickCount + HeroAbilities[hero]["TOWER"].Delay
        SetTimer(Place, -HeroAbilities[hero]["TOWER"].Delay)

        Place(){
            for i, towernumber in HeroAbilities[hero]["TOWER"].Numbers
                ControlSend("{Blind}{" . towernumber . "}", , DDAexe)
        }

    }
}

CleanWrench(){
    if State.ToggleRepair
    {
        if(PixelValues["wrench"].s != 0){
            ControlClick(,DDAexe, , "RIGHT") 
        }
    }
}

UpdateWrench(){
    if State.ToggleMouseRepair {
        CheckColorFuzzy("wrench",GetMousePos(Resolutions[Res].MouseRepairOffset), RepairColors, 300)
    }else{
        CheckColorFuzzy("wrench",WindowOffset(Resolutions[Res].Repair), RepairColors, 300)
    }
}

Repair(){
    if State.ToggleRepair {
        if(PixelValues["wrench"].s == 0){
            ControlSend("{Blind}{r}", , DDAexe)
        }
        else if(PixelValues["wrench"].s == "greenwrench"){
            ControlClick(,DDAexe, , "LEFT")
        }
    }
}

ToggleAutoAttack(){
    if HeroAbilities[hero]["A"]{
        if HeroAbilities[hero]["A"] == "Repair"{
            ToggleState("ToggleMouseRepair", "Mouse Repair")
        }else{
            ToggleState("ToggleAutoAttack", "Auto Attack")
        }
    }
}

AutoAttack(){
    if HeroAbilities[hero]["A"] != "Repair" && State.ToggleAutoAttack{
        if HeroAbilities[hero]["A"] == "BOTHLR"{ ; Works best for Melee weapons with an attack speed of a multiple of 50(ms)
            ControlClick(,DDAexe, , "LEFT")
            SetTimer(RMBD, -5)
            SetTimer(RMBU, -49)
        } else {
            ControlClick(,DDAexe, , HeroAbilities[hero]["A"],, "D")
        }
        if HeroAbilities[hero]["ATOWER"]{
            for i, towernumber in HeroAbilities[hero]["ATOWER"].Numbers
                SetTimer(SendTower.Bind(towernumber), -10*i)
        }
    }

    RMBD(){
        ControlClick(,DDAexe, , "RIGHT",, "D")
    }

    RMBU(){
        ControlClick(,DDAexe, , "RIGHT",, "U")
    }

    SendTower(tower){
        ControlSend("{Blind}{" tower "}", , DDAexe)
    }
}

ToggleState(statestr, text, terinary := 1) {
    State.%statestr% := State.%statestr% == terinary ? 0 : terinary
    Show(text " : ", State.%statestr% ? "ON":"OFF", "")
}

^DEL:: ExitApp
^!R:: Resize(960, 540)
^!T:: ToggleState("ToggleSummaryShutdown", "Summary Shutdown")
F7:: ToggleState("ToggleDebug", "Debug")
F8:: ToggleState("ToggleRepair", "Auto Repair") 
^F8:: ToggleState("ToggleManaDump", "Auto Dump Mana")
F9:: ToggleState("ToggleAutoG", "Auto G", 1)
^F9:: ToggleState("ToggleAutoG", "Force G", 2)
F10:: ToggleState("ToggleHeroBuff", "Auto Hero Buff")
^F10:: ToggleState("ToggleHeroSkill", "Auto Hero Skill") 
F11:: ToggleState("ToggleTowerBuff", "Auto Tower Buff") 
#HotIf WinActive(DDAexe)
^RButton:: ToggleAutoAttack()

Update()


SetTimer(Scan, 250)
SetTimer(Logic, 50)

global initialscan := 0
global phasescan := 0
global heroscan := 0
global togglescan := 0
global repairscan := 0


Scan() {
    GetWindowCoords()
    if WindowCoords.init == 0 {
        return
    }

    if !(WinGetAtCoords(WindowOffset(Resolutions[Res].Phase)) == DDAexe) {
        if initialscan == 1 {
            UpdatePixelValues("phase", WindowOffset(Resolutions[Res].Phase), "blind", PhaseColors, 600)
        }
    } else {
        CheckColorFuzzy("phase", WindowOffset(Resolutions[Res].Phase), PhaseColors, 600)
        State.lastphase := PixelValues["phase"].s
        global phasescan := 1
    }

    if !(WinGetAtCoords(WindowOffset(Resolutions[Res].ToggleC)) == DDAexe) {
        if initialscan == 1 {
            UpdatePixelValues("togglec", WindowOffset(Resolutions[Res].ToggleC), "blind", ToggleColors, 1500)
        }
    } else {
        CheckColorFuzzy("togglec", WindowOffset(Resolutions[Res].ToggleC), ToggleColors, 1500)
        global togglescan := 1
    }

    if !(WinGetAtCoords(WindowOffset(Resolutions[Res].ToggleF)) == DDAexe) {
        if initialscan == 1 {
            UpdatePixelValues("togglef", WindowOffset(Resolutions[Res].ToggleF), "blind", ToggleColors, 1500)
        }
    } else {
        CheckColorFuzzy("togglef", WindowOffset(Resolutions[Res].ToggleF), ToggleColors, 1500)
        global togglescan := 1
    }

    if (WinGetAtCoords(WindowOffset(Resolutions[Res].Repair)) == DDAexe) {
        UpdateWrench()
        global repairscan := 1
    } else {
        if repairscan {
            PixelValues["wrench"].e := WinGetAtCoords(WindowOffset(Resolutions[Res].Repair))
        }
    }

    if !(WinGetAtCoords(WindowOffset(Resolutions[Res].Hero)) == DDAexe) {
        if heroscan {
            PixelValues["hero"].e := WinGetAtCoords(WindowOffset(Resolutions[Res].Hero))
        }
    } else {
        CheckColorFuzzy("hero", WindowOffset(Resolutions[Res].Hero), HeroColors)
        global heroscan := 1
    }

    if heroscan && phasescan && togglescan {
        global initialscan := 1
    }
}

Logic(){
	if WindowCoords.init == 0 || initialscan == 0 {
        ShowDebug()
		return
    }
    global phase := PixelValues["phase"].s
    global hero := PixelValues["hero"].s
    if State.PostMapover == 1
        Show("Shutting down in " Round((State.NextShutdown - A_TickCount) / 1000, 2) " seconds : ", "information",  "")
    if(phase == "mapover" || State.PostMapover == 1) {
	    if State.ToggleSummaryShutdown {
            G(ignoreState := true)
	    	ShutdownTimer()
	    }
    }
    if(phase == "loading") {
        ControlSend("{Blind}{Space}", , DDAexe)
        if State.ToggleAutoG{
            State.PostWarmup := true
        }
        return
    } else if(phase == "warmup") {
		G()
        if State.ToggleAutoG{
            State.PostWarmup := true
        }
    } else if(phase == "build"){
        if State.PostWarmup == false {
            if HeroAbilities[hero]["TOWER"] {
                if HeroAbilities[hero]["TOWER"].Type == "HeroSkill" && State.ToggleHeroBuff { ; Others are not currently added
                    CleanWrench()
                    PlaceTowers(hero)
                }
            }
			G()
        }
        M()
    }
    if(phase == "combat" || phase == "boss" || phase == "tavern" || phase == "blind") {
        State.PostMapover := 0
        if phase == "combat" || phase == "boss" {
            State.PostWarmup := false
        }
        if phase == "blind" && State.PostWarmup == false{
            G()
        }
        if HeroAbilities[hero]["C"] {
            if (HeroAbilities[hero].C.Type == "TowerBuff" && State.ToggleTowerBuff) || 
			   (HeroAbilities[hero].C.Type == "HeroBuff" && State.ToggleHeroBuff) ||
               (HeroAbilities[hero].C.Type == "HeroSkill" && State.ToggleHeroSkill) || 
			   (HeroAbilities[hero].C.Type == "Both" && (State.ToggleHeroBuff || State.ToggleTowerBuff)) {
                if (HeroAbilities[hero].C.Recast == "ToggleC" || HeroAbilities[hero].C.Recast == "M2ToggleC"){
                    if PixelValues["togglec"].s != "blind" {
                        if PixelValues["togglec"].s == 0 && A_TickCount > State.NextInput {
                            CleanWrench()
                            ControlSend("{Blind}{c}", , DDAexe)
                            State.NextInput := A_TickCount + HeroAbilities[hero].C.AnimT
                        }
                        if PixelValues["togglec"].s != 0 && HeroAbilities[hero].C.Recast == "M2ToggleC" && A_TickCount > State.NextC && A_TickCount > State.NextInput{
                            CleanWrench()
                            M2()
                            SetTimer(DeBoost, - HeroAbilities[hero].C.M2AnimT)

                            State.NextInput := A_TickCount + HeroAbilities[hero].C.M2AnimT
                            State.NextC := A_TickCount + HeroAbilities[hero].C.M2Recast + HeroAbilities[hero].C.M2AnimT 

                            DeBoost(){
                                CleanWrench()
                                ControlSend("{Blind}{c}", , DDAexe)
                            }

                            M2(){
                                CleanWrench()
                                ControlClick(,DDAexe, , "RIGHT")
                            }
                        }
                    }
                    else{
                        if HeroAbilities[hero].C.Recast == "M2ToggleC" && A_TickCount > State.NextC && A_TickCount > State.NextInput {
                            ControlSend("{Blind}{c}", , DDAexe)
                            SetTimer(M2, - HeroAbilities[hero].C.AnimT)
                            SetTimer(DeBoost, - (HeroAbilities[hero].C.AnimT + HeroAbilities[hero].C.M2AnimT))

                            State.NextC := A_TickCount + HeroAbilities[hero].C.AnimT + HeroAbilities[hero].C.M2AnimT + HeroAbilities[hero].C.Cooldown
                            State.NextInput := A_TickCount + HeroAbilities[hero].C.AnimT + HeroAbilities[hero].C.M2AnimT + HeroAbilities[hero].C.Cooldown
                        }
                    }
                }
            }
        }
        if HeroAbilities[hero]["F"] {
			if (HeroAbilities[hero].F.Type == "TowerBuff" && State.ToggleTowerBuff) || 
			   (HeroAbilities[hero].F.Type == "HeroBuff" && State.ToggleHeroBuff) ||
               (HeroAbilities[hero].F.Type == "HeroSkill" && State.ToggleHeroSkill) ||  
			   (HeroAbilities[hero].F.Type == "Both" && (State.ToggleHeroBuff || State.ToggleTowerBuff)) {
				if (HeroAbilities[hero].F.Recast == "ToggleF"){
					if PixelValues["togglef"].s != "blind" {
                        if PixelValues["togglef"].s == 0 && A_TickCount > State.NextInput {
                            CleanWrench()
                            ControlSend("{Blind}{f}", , DDAexe)
                            State.NextInput := A_TickCount + HeroAbilities[hero].F.AnimT
                        }
                    }
				}
                else if (HeroAbilities[hero].F.Recast == "TimerToggleF") {
                    if A_TickCount > State.NextF && A_TickCount > State.NextInput {
                        CleanWrench()
                        ControlSend("{Blind}{f}", , DDAexe)
                        State.NextF := A_TickCount + HeroAbilities[hero].F.AnimT + HeroAbilities[hero].F.Cooldown
                        State.NextInput := A_TickCount + HeroAbilities[hero].F.AnimT
                    }
                }
			}
        }
        if A_Tickcount > State.NextInput + 50 {
            Repair()
            AutoAttack()
        }
    }
    ShowDebug()
}

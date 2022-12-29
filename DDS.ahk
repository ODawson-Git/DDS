#SingleInstance Force
#Requires AutoHotkey v2.0-beta

v := 221229 ;YYMMDD

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

DDAexe := "ahk_exe DDS-Win64-Shipping.exe" ;You can use Window Spy to see the exe name

State := {  AutoG : false,
            ToggleHeroBuff : false,
            ToggleTowerBuff : false,
            ToggleRepair : false,
            ToggleMouseRepair : false,
            RenderDebug : false,
            DumpMana : false,
            PostWarmup : false,
            NextF : 0,
            NextC : 0,
            NextM : 0,
            NextG : 0,
            NextM2 : 0,
            NextInput : 0,
            lastphase : "0"}

Resolutions := {
    ;1920x1440: {Phase:{x:12345,y:12345}, Hero:{x:12345,y:12345}, Toggle:{x:12345,y:12345} },
    1920x1080:  {Phase:{x:1853,y:63}, Hero:{x:44,y:82}, Toggle:{x:1645,y:837}, Repair:{x:973, y:531}, MouseRepairOffset:{x:-1, y:-1}},
    1280x720:   {Phase:{x:1235,y:40}, Hero:{x:29,y:53}, Toggle:{x:1096,y:558}, Repair:{x:649, y:355}, MouseRepairOffset:{x:-1, y:-1}}
    ;3072x1920: {Phase:{x:12345,y:12345}, Hero:{x:12345,y:12345}, Toggle:{x:12345,y:12345} }320 160
}

; boss colors hasn't been set up yet
PhaseColors := {
    mapover:    {R: 0,          G: 77,          B: 119,     Rm: 7  ,         Gm: 55,        Bm: 94  }, 
    warmup:     {R: 148,        G: 106,         B: 0,       Rm: 105,         Gm: 73,        Bm: 16  }, 
    build:      {R: 75,         G: 124,         B: 0,       Rm: 57 ,         Gm: 85,        Bm: 16  }, 
    combat:     {R: 127,        G: 25,          B: 39,      Rm: 90 ,         Gm: 20,        Bm: 42  }, 
    tavern:     {R: 165,        G: 89,          B: 0,       Rm: 115,         Gm: 62,        Bm: 16  }, 
    boss:       {R: 133,        G: 0,           B: 115,     Rm: 112  ,       Gm: 24,        Bm: 109   },
    loading:    {R: 154,        G: 36,          B: 0,       Rm: 154,         Gm: 36,        Bm: 0   },
    inventory:  {R: 106,        G: 106,         B: 106,     Rm: 106,         Gm: 106,       Bm: 106 }
}

ToggleColors := {
    on:       {R: 0,        G: 122,         B: 122,     Rm: 39,     Gm: 72,     Bm: 92 }, 
    off:      {R: 7,        G: 5,           B: 16,      Rm: 42,     Gm: 45,     Bm: 64 }
}

RepairColors := {
    redwrench:      {R: 255,    G: 0,       B: 0,     Rm: 255,      Gm: 0,     Bm: 0 },
    greenwrench:    {R: 0,      G: 255,     B: 0,     Rm: 0,        Gm: 255,   Bm: 0 }
}

HeroColors := {
    apprentice:  {R: 2,         G: 131,         B: 204,   Rm: 15,      Gm: 87,     Bm: 141}, 
    monk:        {R: 229,       G: 102,         B: 32,    Rm: 148,     Gm: 70,     Bm: 41 }, 
    squire:      {R: 165,       G: 18,          B: 18,    Rm: 110,     Gm: 21,     Bm: 32 }, 
    huntress:    {R: 0,         G: 127,         B: 57,    Rm: 13,      Gm: 84,     Bm: 55 }, 
    ev:          {R: 122,       G: 31,          B: 185,   Rm: 85,      Gm: 29,     Bm: 130}, 
    warden:      {R: 85,        G: 75,          B: 79,    Rm: 57,      Gm: 53,     Bm: 64 }, 
    rogue:       {R: 87,        G: 5,           B: 54,    Rm: 64,      Gm: 14,     Bm: 54 }, 
    summoner:    {R: 54,        G: 52,          B: 85,    Rm: 46,      Gm: 40,     Bm: 72 }
}

HeroAbilities := {
    apprentice: {A: "LEFT",                                                     C: {Type: "Tower", AnimT: 1250, Recast: "M2Toggle", M2AnimT: 1500, M2Recast: 7000}}, 
    monk:       {A: "RIGHT",    F: {Type: "Tower", AnimT: 500, Recast: 19000},  C:{Type: "Hero", AnimT: 500, Recast: "Toggle"}}, 
    squire:     {A: "LEFT",                                                     C: {Type: "Hero", AnimT: 500, Recast: "Toggle"}}, 
    huntress:   {A: "LEFT",                                                     C: {Type: "Hero", AnimT: 500, Recast: "Toggle"}}, 
    ev:         {A: "LEFT"},    
    warden:     {A: "LEFT",                                                     C: {Type: "Both", AnimT: 500, Recast: "Toggle"}}, 
    rogue:      {A: "LEFT"}, 
    summoner:   {A: "Repair",   F: {Type: "Tower", AnimT: 2000, Recast: 5100},  C:{Type: "Hero", AnimT: 500, Recast: "Toggle"}}
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
            MsgBox("Resolution not supported")
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

GetMousePos(offset:= 0){ ;only works on Windows Scaling 100%
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
    PixelValues[Varname] := {s: Ret, r: R, g: G, b: B, x: Coord.x, y: Coord.y, u: A_TickCount}
}

GUIColors := {
	backcolor:      "C25292E", 
	information:    "C60D9EF", 
    ON:             "C7CFC00", 
	OFF:            "CDC143C"
}

ShowDebug(){
    ShowGUI := Gui()
    ShowGUI.Opt("+AlwaysOnTop -Caption +ToolWindow")
    ShowGUI.SetFont("s11")
    ShowGUI.BackColor := GUIColors.backcolor
    for k, v in PixelValues
        ShowGUI.Add("Text", GUIColors.information, k "  -  " v.s "      " v.r "  " v.g "  " v.b "      " Round(v.x) "  " Round(v.y) "      " v.u)
    for k, v in State.OwnProps()
        ShowGUI.Add("Text", v ? GUIColors.ON : GUIColors.OFF, k "  -  " v)
    ShowGUI.Show("y" A_ScreenHeight " NoActivate") ;Show out of viewing area to get dimensions
    ShowGUI.GetPos(, , &GWidth, &GHeight) ;GetPos only works when GUI active
    ShowGUI.Move(WindowCoords.x, WindowCoords.y + WindowCoords.h*0.5 - GHeight*0.5)
    Cleanup(){
        ShowGUI.Destroy() 
    }
    SetTimer(Cleanup,-100)
}

Show(text, state, text2){
    ShowGUI := Gui()
    ShowGUI.Opt("+AlwaysOnTop -Caption +ToolWindow")
    ShowGUI.SetFont("s11")
    ShowGUI.BackColor := GUIColors.backcolor
    ShowGUI.Add("Text", GUIColors.%state%, text state text2)
    ShowGUI.Show(" y -100" " NoActivate") ;Show out of viewing area to get dimensions
    ShowGUI.GetPos(, , &GWidth, &GHeight) ;GetPos only works when GUI active
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

G(){
    if State.AutoG && A_TickCount > State.NextG {
        if State.AutoG > 1 {
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
        else
        {
            State.NextG := A_TickCount + 1000
            ControlSend("{Blind}{g down}", , DDAexe)
            GUp(){
                ControlSend("{Blind}{g up}", , DDAexe)
            }
            SetTimer(GUp,-420)
        }
        
    }
}

M(){
    if State.DumpMana && A_TickCount > State.NextM
    {
        State.NextM := A_TickCount + 1000
        ControlSend("{Blind}{m down}", , DDAexe)
        ManaUp(){
            ControlSend("{Blind}{m up}", , DDAexe)
        }
        SetTimer(ManaUp,-550)
    }
}

Repair(){
    if State.ToggleMouseRepair {
        CheckColorFuzzy("wrench",GetMousePos(Resolutions[Res].MouseRepairOffset), RepairColors, 300)
    }else{
        CheckColorFuzzy("wrench",WindowOffset(Resolutions[Res].Repair), RepairColors, 300)
    }
    wrench := PixelValues["wrench"].s
    if(wrench == 0){
        ControlSend("{Blind}{r}", , DDAexe)
    }
    else if(wrench == "greenwrench"){
        ControlClick(,DDAexe, , "LEFT")
        SetTimer(Cleanup,-200) ;200ms max repair time (has to be less than timer for Repair())

        Cleanup(){
            if State.ToggleMouseRepair {
                CheckColorFuzzy("wrench",GetMousePos(Resolutions[Res].MouseRepairOffset), RepairColors, 300)
            }else{
                CheckColorFuzzy("wrench",WindowOffset(Resolutions[Res].Repair), RepairColors, 300)
            }
            if(PixelValues["wrench"].s != 0){
                ControlClick(,DDAexe, , "RIGHT") 
            }
        }
    }
}

AutoAttack(){
    if HeroAbilities[hero]["A"]{
        if HeroAbilities[hero]["A"] == "Repair"{
            ToggleState("ToggleMouseRepair", "Mouse Repair")
        }else{
            Show("Auto Attack : ", "ON", "")
            ControlClick(,DDAexe, , HeroAbilities[hero]["A"], , "D")
        }
    }
}

CleanWrench(){
    if State.ToggleRepair
    {
        CheckColorFuzzy("wrench",WindowOffset(Resolutions[Res].Repair), RepairColors, 300)
        if(PixelValues["wrench"].s != 0){
            ControlClick(,DDAexe, , "RIGHT") 
        }
    }
}

ToggleState(statestr,text,terinary := 1){
    State.%statestr% := State.%statestr% == terinary ? 0 : 1
    Show(text " : ", State.%statestr% ? "ON":"OFF", "")
}

^RButton:: AutoAttack()
^DEL:: ExitApp
F7:: ToggleState("DumpMana", "Auto Dump Mana")
F8:: ToggleState("RenderDebug", "Debug")
F9:: ToggleState("AutoG", "Auto G", 1)
^F9:: ToggleState("AutoG", "Force G", 2)
F10:: ToggleState("ToggleHeroBuff", "Auto Hero Buff") 
F11:: ToggleState("ToggleTowerBuff", "Auto Tower Buff") 
F12:: ToggleState("ToggleRepair", "Auto Repair") 

Update()

SetTimer(Scan, 250)
SetTimer(Logic, 50)

global initialscan := 0

Scan(){
    GetWindowCoords()
	if WindowCoords.init == 0
		return
    CheckColorFuzzy("phase",WindowOffset(Resolutions[Res].Phase), PhaseColors) 
    if (PixelValues["phase"].s != "combat" && PixelValues["phase"].s != "boss") || 
        (PixelValues["phase"].s == "combat" && State.lastphase != "combat") || 
        (PixelValues["phase"].s == "boss" && (State.lastphase != "combat" || State.lastphase != "boss"))
        CheckColorFuzzy("hero",WindowOffset(Resolutions[Res].Hero), HeroColors)
        CheckColorFuzzy("toggle",WindowOffset(Resolutions[Res].Toggle), ToggleColors)
    global hero := PixelValues["hero"].s
    State.lastphase := PixelValues["phase"].s
    global initialscan := 1
}

Logic(){
	if WindowCoords.init == 0 || initialscan == 0
		return
    phase := PixelValues["phase"].s
    if(phase == "loading") {
        ControlSend("{Blind}{Space}", , DDAexe)
        State.PostWarmup := true
        return
    } else if(phase == "warmup") {
		G()
        State.PostWarmup := true
    } else if(phase == "build"){
        if State.PostWarmup == false
			G()
            M()
    }
    hero := PixelValues["hero"].s
    if(phase == "combat" || phase == "boss" || phase == "tavern") {
        State.PostWarmup := false
        if HeroAbilities[hero]["C"] {
            if (HeroAbilities[hero].C.Type == "Tower" && State.ToggleTowerBuff) || 
			   (HeroAbilities[hero].C.Type == "Hero" && State.ToggleHeroBuff) || 
			   (HeroAbilities[hero].C.Type == "Both" && (State.ToggleHeroBuff || State.ToggleTowerBuff)) {
                if HeroAbilities[hero].C.Recast == "Toggle" || HeroAbilities[hero].C.Recast == "M2Toggle" {
                    if PixelValues["toggle"].s == "off" && A_TickCount > State.NextInput {
                        CleanWrench()
                        ControlSend("{Blind}{c}", , DDAexe)
                        State.NextInput := A_TickCount + HeroAbilities[hero].C.AnimT
                    }
                    if PixelValues["toggle"].s == "on" && HeroAbilities[hero].C.Recast == "M2Toggle" && A_TickCount > State.NextM2 && A_TickCount > State.NextInput{
                        CleanWrench()
                        ControlClick(,DDAexe, , "RIGHT")
                        State.NextInput := A_TickCount + HeroAbilities[hero].C.M2AnimT

                        SetTimer(DeBoost, - HeroAbilities[hero].C.M2AnimT)
                        State.NextM2 := A_TickCount + HeroAbilities[hero].C.M2Recast + HeroAbilities[hero].C.M2AnimT 

                        DeBoost(){
                            CleanWrench()
                            ControlSend("{Blind}{c}", , DDAexe)
                        }
                    } 
                }
                ;else if A_TickCount > LastC + HeroAbilities[hero].C.AnimT + HeroAbilities[hero].C.Recast {
                ;     Only used by rogue hop, scripted movement not supported
                ;}
            }
        }
        if HeroAbilities[hero]["F"] {
			if (HeroAbilities[hero].F.Type == "Tower" && State.ToggleTowerBuff) || 
			   (HeroAbilities[hero].F.Type == "Hero" && State.ToggleHeroBuff) || 
			   (HeroAbilities[hero].F.Type == "Both" && (State.ToggleHeroBuff || State.ToggleTowerBuff)) {
				if HeroAbilities[hero].F.Recast == "Toggle" || HeroAbilities[hero].F.Recast == "M2Toggle" {
					; These don't currently exist ingame
				}
				else if A_TickCount > State.NextF && A_TickCount > State.NextInput {
                    CleanWrench()
					ControlSend("{Blind}{f}", , DDAexe)
					State.NextF := A_TickCount + HeroAbilities[hero].F.AnimT + HeroAbilities[hero].F.Recast
					State.NextInput := A_TickCount + HeroAbilities[hero].F.AnimT
				}
			}
        }
        if State.ToggleRepair && A_Tickcount > State.NextInput + 225 
            Repair()
    }
    if State.RenderDebug
        ShowDebug()
}

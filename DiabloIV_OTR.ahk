#Persistent
#NoEnv
#SingleInstance force
SetWorkingDir %A_ScriptDir%

;add your own ico in the same folder as the script
trayico = %A_ScriptDir%\D4icon.ico
FileInstall, D4icon.ico, %trayico%, 1
Menu, Tray, Icon, %trayico%

;add your own picture in the same folder as the script
picture = %A_ScriptDir%\lilith.png
FileInstall, lilith.png, %picture%, 1

;Define Screen related measures--------------------------------
midX := (A_ScreenWidth // 2) ;Screen mid width
midY := (A_ScreenHeight // 2) ;Screen mid height
offset = 0
RedMin = 255
BlueMin = 255
GreenMin = 255
gosub ReadINI

;Check if OTR can be found, if not ask for the path, if not ask to download
if !FileExist(OTRpath)
{
	FileSelectFile, OTRpath, 3, C:\Program Files (x86)\OnTopReplica\OnTopReplica\OnTopReplica.exe, Select OnTopReplica.exe, *.exe
	if (OTRpath = "")
	{
		MsgBox, 17, OnTopReplica not found, Download OnTopReplica from https://github.com/LorenzCK/OnTopReplica
		IfMsgBox, OK
		{
			Run, msedge.exe "https://github.com/LorenzCK/OnTopReplica"
			gosub ExitScript
		}
		IfMsgBox, Cancel
			gosub ExitScript
	}
}


;Decide where the buttons are based on the screen resolution
if A_ScreenHeight = 1440
{
	sourceWidth = 73 ;width of each skill button
	sourcePadding = 11 ;padding between skills
	barY = 1305 ;top Y coordinate of skill buttons
	barX := midX ;skill bar Center
	mapWidth = 495 ;Map width, this is wider than the actual map as the zone names can be wider than the map itself
	mapHeight = 360
	if A_ScreenWidth = 5120 ; 5120x1440 32:9
	{
		barOffset := barX - 1118 ;The numerical value here is the X center of the skill bar when HUD is set to LEFT
		mapX = 4217 ;Map left corner
	}
	else if A_ScreenWidth = 2560 ;2560x1440 16:9
	{
		barOffset := barX - 720
		mapX = 2065
	}
	else if A_ScreenWidth = 3440 ;3440x1440 21:9
	{
		barOffset := barX - 0000 ;The numerical value here is the X center of the skill bar when HUD is set to LEFT
		mapX = 0000 ;Map left corner

	}
	else
		msgbox, resolution not supported yet
}
else if A_ScreenHeight = 1080
{
	sourceWidth = 56
	sourcePadding = 7
	barY = 978
	barX := midX ; Bar Center
	mapWidth = 370
	mapHeight = 270
	if A_ScreenWidth = 3840 ;3840x1080 32:9
	{
		barOffset := barX - 839
		mapX = 3170
	}
	else if A_ScreenWidth = 1920 ;1920x1080 16:9
	{
		barOffset := barX - 538
		mapX = 1550
	}
	else if A_ScreenWidth = 2560 ;2560x1080 21:9
	{
		barOffset := barX - 0000 ;The numerical value here is the X center of the skill bar when HUD is set to LEFT
		mapX = 0000 ;Map left corner
	}
	else
		msgbox, resolution not supported yet
}
else
	msgbox, resolution not supported yet


;Draw the GUI--------------------------------------------------------------------------------------------------------------------------
Gui +OwnDialogs +LastFound
Gui, Color, 8f0e04
Gui, Font, cWhite
Gui Add, Text, x10 y10 w500 h20, Resolution: %A_ScreenWidth% x %A_ScreenHeight%
;Gui Add, DropDownList, x110 y10 w150 h200 vResolution, 5120x1440|3840x1080|3440x1440|2560x1080|2560x1440|1920x1080|1600x900|1280x720
Gui Add, Text, x10 y40 w100 h20, Hud Configuration:
Gui Add, DropDownList, x110 y40 w150 h100 vBarPosition AltSubmit Choose%BarPosition%, Center|Left|
Gui Add, Text, x280 y40 w300 h100, (This can be changed in Options > Gameplay)
Gui Add, Text, x10 y70 w100 h20, Skills:
Gui Add, Checkbox, x110 y70 w70 h20 vSkill1 Checked%Skill1%, Skill 1
Gui Add, Checkbox, x190 y70 w70 h20 vSkill2 Checked%Skill2%, Skill 2
Gui Add, Checkbox, x270 y70 w70 h20 vSkill3 Checked%Skill3%, Skill 3
Gui Add, Checkbox, x350 y70 w70 h20 vSkill4 Checked%Skill4%, Skill 4
Gui Add, Checkbox, x430 y70 w90 h20 vLeftSkill Checked%LeftSkill%, Left Skill
Gui Add, Checkbox, x530 y70 w90 h20 vRightSkill Checked%RightSkill%, Right Skill
Gui Add, Text, x10 y100 w100 h20, Skills Position:
Gui, Font, cBlack
Gui Add, Edit, x110 y100 w50 h20 vSkillsPosX, %SkillsPosX%
Gui Add, Button, x160 y100 w20 h20 gIncreaseSkillsPosX, +
Gui Add, Button, x180 y100 w20 h20 gDecreaseSkillsPosX, -
Gui Add, Edit, x200 y100 w50 h20 vSkillsPosY, %SkillsPosY%
Gui Add, Button, x250 y100 w20 h20 gIncreaseSkillsPosY, +
Gui Add, Button, x270 y100 w20 h20 gDecreaseSkillsPosY, -
Gui, Font, cWhite
Gui Add, Text, x10 y130 w100 h20, Skills Size:
Gui, Font, cBlack
Gui Add, Edit, x110 y130 w50 h20 vSkillsSizeX, 40
Gui Add, Button, x160 y130 w20 h20 gIncreaseSkillsSizeX, +
Gui Add, Button, x180 y130 w20 h20 gDecreaseSkillsSizeX, -
;Gui Add, Edit, x200 y130 w50 h20 vSkillsSizeY,
;Gui Add, Button, x250 y130 w20 h20 gIncreaseSkillsSizeY, +
;Gui Add, Button, x270 y130 w20 h20 gDecreaseSkillsSizeY, -
Gui, Font, cWhite
Gui Add, Text, x10 y160 w150 h20, Skills Opacity:    Invisible
Gui Add, Slider, x130 y160 w150 h20 vSkillsOpacity Range0-255 TickInterval25 ToolTip, %SkillsOpacity%
Gui Add, Text, x285 y160 w150 h20, Solid
Gui Add, Text, x10 y190 w100 h20, Padding:
Gui, Font, cBlack
Gui Add, Edit, x110 y190 w50 h20 vPadding, %Padding%
Gui, Font, cWhite
Gui Add, Text, x10 y230 w100 h20, Map:
Gui, Font, cWhite
Gui Add, Checkbox, x110 y230 w70 h20 vMap Checked%Map%
Gui Add, Text, x10 y250 w100 h20, Map Position:
Gui, Font, cBlack
Gui Add, Edit, x110 y250 w50 h20 vMapPosX, %MapPosX%
Gui Add, Button, x160 y250 w20 h20 gIncreaseMapPosX, +
Gui Add, Button, x180 y250 w20 h20 gDecreaseMapPosX, -
Gui Add, Edit, x200 y250 w50 h20 vMapPosY, %MapPosY%
Gui Add, Button, x250 y250 w20 h20 gIncreaseMapPosY, +
Gui Add, Button, x270 y250 w20 h20 gDecreaseMapPosY, -
Gui, Font, cWhite
Gui Add, Text, x10 y280 w100 h20, Map Width:
Gui, Font, cBlack
Gui Add, Edit, x110 y280 w50 h20 vMapSizeX, %MapSizeX%
Gui Add, Button, x160 y280 w20 h20 gIncreaseMapSizeX, +
Gui Add, Button, x180 y280 w20 h20 gDecreaseMapSizeX, -
Gui, Font, cWhite
Gui Add, Text, x10 y310 w150 h20, Map Opacity:    Invisible
Gui Add, Slider, x130 y310 w150 h20 vMapOpacity Range0-255 TickInterval25 ToolTip, %MapOpacity%
Gui Add, Text, x285 y310 w150 h20, Solid
Gui Add, Button, x10 y340 w100 h30 gRunButton, Apply (⊞ ⇑ R)
Gui Add, Button, x120 y340 w100 h30 gHideAll, Hide (⊞ ⇑ H)
Gui Add, Button, x230 y340 w100 h30 gExitScript, Quit (⊞ ⇑ Q)
Gui, add, Picture, w266 h239 x345 y110, %picture%
Gui Show, , GUI Diablo IV Overlay

SetTimer, HideInactive, 250
return
;Draw the GUI--------------------------------------------------------------------------------------------------------------------------


#+r::
RunButton:
Gui, Submit, NoHide
gosub, SaveChanges
gosub, KillAll ;Close all the OTR windows
;Check if D4 is running
IfWinNotExist, Diablo IV
{
	MsgBox, 16, Diablo IV not running, The program has not found Diablo IV. Make sure that Diablo IV is running before pressing the Apply button, 10
	return
}
;Change the positions if the LEFT option is selected
if (BarPosition = 2)
	offset := barOffset
nButtons = 0 ;init
order = 1 ;counter init, used to calculate positions and assign processID
nButtons := Skill1 + Skill2 + Skill3 + Skill4 + RightSkill + LeftSkill ;count how many buttons we are going to draw

pos1 := skillsPosX -  Floor((nButtons/2) * SkillsSizeX) - Floor(((nButtons/2)-0.5)*Padding) ;find out where the 1st position is going to be based on the number of skills
pos2 := pos1 + SkillsSizeX + Padding
pos3 := pos2 + SkillsSizeX + Padding
pos4 := pos3 + SkillsSizeX + Padding
pos5 := pos4 + SkillsSizeX + Padding
pos6 := pos5 + SkillsSizeX + Padding

sk1PixX := floor(barX + (-3 * sourceWidth ) + ((-3 + 0.5) * sourcePadding)) - offset +10
sk1PixY := barY - 1

if (Skill1){
	skillN = -3 ; where is this skill relative to the center of the bar
	sourceX := floor(barX + (skillN * sourceWidth ) + ((skillN + 0.5) * sourcePadding)) - offset
	thisPos := % pos%order% ;where is this OTR going to be placed
	cmd1 := OTRpath . " --windowTitle=""Diablo IV"" --size=" . SkillsSizeX . "`," . SkillsSizeX . " --region=" . sourceX . "`," . barY . "`," . sourceWidth . "`," . sourceWidth . " --position=" . thisPos . "`," . SkillsPosY . " --opacity=" . SkillsOpacity . " --chromeOff"
	run, %cmd1% ,,, idSkill%order%	
	order++
}
if (Skill2){
	skillN = -2
	sourceX := floor(barX + (skillN * sourceWidth ) + ((skillN + 0.5) * sourcePadding)) - offset
	thisPos := % pos%order%
	cmd1 := OTRpath . " --windowTitle=""Diablo IV"" --size=" . SkillsSizeX . "`," . SkillsSizeX . " --region=" . sourceX . "`," . barY . "`," . sourceWidth . "`," . sourceWidth . " --position=" . thisPos . "`," . SkillsPosY . " --opacity=" . SkillsOpacity . " --chromeOff"
	run, %cmd1% ,,, idSkill%order%
	order++
}
if (Skill3){
	skillN = -1
	sourceX := floor(barX + (skillN * sourceWidth ) + ((skillN + 0.5) * sourcePadding))- offset
	thisPos := % pos%order%
	cmd1 := OTRpath . " --windowTitle=""Diablo IV"" --size=" . SkillsSizeX . "`," . SkillsSizeX . " --region=" . sourceX . "`," . barY . "`," . sourceWidth . "`," . sourceWidth . " --position=" . thisPos . "`," . SkillsPosY . " --opacity=" . SkillsOpacity . " --chromeOff"
	run, %cmd1% ,,, idSkill%order%
	order++
}
if (Skill4){
	skillN = 0
	sourceX := floor(barX + (skillN * sourceWidth ) + ((skillN + 0.5) * sourcePadding))- offset
	thisPos := % pos%order%
	cmd1 := OTRpath . " --windowTitle=""Diablo IV"" --size=" . SkillsSizeX . "`," . SkillsSizeX . " --region=" . sourceX . "`," . barY . "`," . sourceWidth . "`," . sourceWidth . " --position=" . thisPos . "`," . SkillsPosY . " --opacity=" . SkillsOpacity . " --chromeOff"
	run, %cmd1% ,,, idSkill%order%
	order++
}
if (LeftSkill){
	skillN = 1
	sourceX := floor(barX + (skillN * sourceWidth ) + ((skillN + 0.5) * sourcePadding))- offset
	thisPos := % pos%order%
	cmd1 := OTRpath . " --windowTitle=""Diablo IV"" --size=" . SkillsSizeX . "`," . SkillsSizeX . " --region=" . sourceX . "`," . barY . "`," . sourceWidth . "`," . sourceWidth . " --position=" . thisPos . "`," . SkillsPosY . " --opacity=" . SkillsOpacity . " --chromeOff"
	run, %cmd1% ,,, idSkill%order%
	order++
}
if (RightSkill){
	skillN = 2
	sourceX := floor(barX + (skillN * sourceWidth ) + ((skillN + 0.5) * sourcePadding))- offset
	thisPos := % pos%order%
	cmd1 := OTRpath . " --windowTitle=""Diablo IV"" --size=" . SkillsSizeX . "`," . SkillsSizeX . " --region=" . sourceX . "`," . barY . "`," . sourceWidth . "`," . sourceWidth . " --position=" . thisPos . "`," . SkillsPosY . " --opacity=" . SkillsOpacity . " --chromeOff"
	run, %cmd1% ,,, idSkill%order%
	order++
}
if (Map){
	cmd2 := OTRpath . " --windowTitle=""Diablo IV"" --width=" . MapSizeX . " --region=" . mapX . "`,0`," . mapWidth . "`," . mapHeight . " --position=" . MapPosX . "`," . MapPosY . " --opacity=" . MapOpacity . " --chromeOff"
	run, %cmd2% ,,, idMap
	order++
}
WinMinimize, GUI Diablo IV Overlay
return

#+b:: ;lifebars/manabars on the sides for 32:9

	gosub RunButton
	cmd3 := OTRpath . " --windowTitle=""Diablo IV"" --width=404 --region=2068`,1236`,45`,169  --opacity=255 --chromeOff --screenPosition=TL"
	run, %cmd3% ,,, idLife
	cmd3 := OTRpath . " --windowTitle=""Diablo IV"" --width=400 --region=3001`,1236`,45`,169  --opacity=255 --chromeOff --screenPosition=TR --position=4716,0 "
	run, %cmd3% ,,, idMana
	TrayTip, Diablo IV Overlay, Showing resource overlays, 2, 1
return




KillAll:
	if (idSkill1)
		process, close, %idSkill1%
	if (idSkill2)
		process, close, %idSkill2%
	if (idSkill3)
		process, close, %idSkill3%
	if (idSkill4)
		process, close, %idSkill4%
	if (idSkill5)
		process, close, %idSkill5%
	if (idSkill6)
		process, close, %idSkill6%
	if (idMap)
		process, close, %idMap%
	if (idLife)
		process, close, %idLife%
	if (idMana)
		process, close, %idMana%
	idSkill1 =
	idSkill2 =
	idSkill3 =
	idSkill4 =
	idSkill5 =
	idSkill6 =
	idMap =
	idLife =
	idMana =
	;TrayTip, Diablo IV Overlay, Closing all overlays, 5, 1
return



#+q::
ExitScript:
GuiClose:
GuiEscape:
	gosub, KillAll
ExitApp

IncreaseSkillsPosX:
    GuiControlGet, SkillsPosX, , SkillsPosX
    SkillsPosX++
    GuiControl,, SkillsPosX, %SkillsPosX%
return

DecreaseSkillsPosX:
    GuiControlGet, SkillsPosX, , SkillsPosX
    SkillsPosX--
    GuiControl,, SkillsPosX, %SkillsPosX%
return

IncreaseSkillsPosY:
    GuiControlGet, SkillsPosY, , SkillsPosY
    SkillsPosY++
    GuiControl,, SkillsPosY, %SkillsPosY%
return

DecreaseSkillsPosY:
    GuiControlGet, SkillsPosY, , SkillsPosY
    SkillsPosY--
    GuiControl,, SkillsPosY, %SkillsPosY%
return

IncreaseSkillsSizeX:
    GuiControlGet, SkillsSizeX, , SkillsSizeX
    SkillsSizeX++
    GuiControl,, SkillsSizeX, %SkillsSizeX%
return

DecreaseSkillsSizeX:
    GuiControlGet, SkillsSizeX, , SkillsSizeX
    SkillsSizeX--
    GuiControl,, SkillsSizeX, %SkillsSizeX%
return

IncreaseSkillsSizeY:
    GuiControlGet, SkillsSizeY, , SkillsSizeY
    SkillsSizeY++
    GuiControl,, SkillsSizeY, %SkillsSizeY%
return

DecreaseSkillsSizeY:
    GuiControlGet, SkillsSizeY, , SkillsSizeY
    SkillsSizeY--
    GuiControl,, SkillsSizeY, %SkillsSizeY%
return

IncreaseMapPosX:
    GuiControlGet, MapPosX, , MapPosX
    MapPosX++
    GuiControl,, MapPosX, %MapPosX%
return

DecreaseMapPosX:
    GuiControlGet, MapPosX, , MapPosX
    MapPosX--
    GuiControl,, MapPosX, %MapPosX%
return

IncreaseMapPosY:
    GuiControlGet, MapPosY, , MapPosY
    MapPosY++
    GuiControl,, MapPosY, %MapPosY%
return

DecreaseMapPosY:
    GuiControlGet, MapPosY, , MapPosY
    MapPosY--
    GuiControl,, MapPosY, %MapPosY%
return

IncreaseMapSizeX:
    GuiControlGet, MapSizeX, , MapSizeX
    MapSizeX++
    GuiControl,, MapSizeX, %MapSizeX%
return

DecreaseMapSizeX:
    GuiControlGet, MapSizeX, , MapSizeX
    MapSizeX--
    GuiControl,, MapSizeX, %MapSizeX%
return

IncreaseMapSizeY:
    GuiControlGet, MapSizeY, , MapSizeY
    MapSizeY++
    GuiControl,, MapSizeY, %MapSizeY%
return

DecreaseMapSizeY:
    GuiControlGet, MapSizeY, , MapSizeY
    MapSizeY--
    GuiControl,, MapSizeY, %MapSizeY%
return

SaveChanges: ;save ini file
Gui, Submit , NoHide
IniWrite, %BarPosition%, settings.ini, General, BarPosition
IniWrite, %Skill1%, settings.ini, General, Skill1
IniWrite, %Skill2%, settings.ini, General, Skill2
IniWrite, %Skill3%, settings.ini, General, Skill3
IniWrite, %Skill4%, settings.ini, General, Skill4
IniWrite, %LeftSkill%, settings.ini, General, LeftSkill
IniWrite, %RightSkill%, settings.ini, General, RightSkill
IniWrite, %Map%, settings.ini, General, Map
IniWrite, %SkillsPosX%, settings.ini, General, SkillsPosX
IniWrite, %SkillsPosY%, settings.ini, General, SkillsPosY
IniWrite, %SkillsSizeX%, settings.ini, General, SkillsSizeX
IniWrite, %SkillsSizeY%, settings.ini, General, SkillsSizeY
IniWrite, %SkillsOpacity%, settings.ini, General, SkillsOpacity
IniWrite, %Padding%, settings.ini, General, Padding
IniWrite, %MapPosX%, settings.ini, General, MapPosX
IniWrite, %MapPosY%, settings.ini, General, MapPosY
IniWrite, %MapSizeX%, settings.ini, General, MapSizeX
IniWrite, %MapOpacity%, settings.ini, General, MapOpacity
IniWrite, %OTRpath%, settings.ini, General, OTRpath
TrayTip, Diablo IV Overlay, Settings saved, 5, 1
return

ReadINI: ;read ini file
IniRead, BarPosition, settings.ini, General, BarPosition, 1
IniRead, Skill1, settings.ini, General, Skill1, 1
IniRead, Skill2, settings.ini, General, Skill2, 1
IniRead, Skill3, settings.ini, General, Skill3, 1
IniRead, Skill4, settings.ini, General, Skill4, 1
IniRead, LeftSkill, settings.ini, General, LeftSkill, 1
IniRead, RightSkill, settings.ini, General, RightSkill, 1
IniRead, Map, settings.ini, General, Map, 0
IniRead, SkillsPosX, settings.ini, General, SkillsPosX, %midX%
IniRead, SkillsPosY, settings.ini, General, SkillsPosY, %midY%
IniRead, SkillsSizeX, settings.ini, General, SkillsSizeX, 40
;IniRead, SkillsSizeY, settings.ini, General, SkillsSizeY
IniRead, SkillsOpacity, settings.ini, General, SkillsOpacity, 200
IniRead, Padding, settings.ini, General, Padding, 16
IniRead, MapPosX, settings.ini, General, MapPosX, 0
IniRead, MapPosY, settings.ini, General, MapPosY, 0
IniRead, MapSizeX, settings.ini, General, MapSizeX, 495
IniRead, MapOpacity, settings.ini, General, MapOpacity, 120
IniRead, OTRpath, settings.ini, General, OTRpath
return


;color MUST be in BGR form
;this function splits the color into its Red, Green, and Blue parts
SplitBGRColor(BGRColor, ByRef Red, ByRef Green, ByRef Blue)
{
    Red := BGRColor & 0xFF
    Green := BGRColor >> 8 & 0xFF
    Blue := BGRColor >> 16 & 0xFF
}

#+h::
HideAll:
;minimize all the OTR windows
WinGet, id, list, OnTopReplica,,,
Loop, %id%
	{
		this_id := id%A_Index%
	
		WinGet, current_window_state, MinMax, ahk_id %this_id%,,,
		; Gets the current window's state of -1, 0, 1 (MinMax)
		;MsgBox %this_id% 's state is %current_window_state%
	
		If (current_window_state == -1) {
			WinRestore, ahk_id %this_id%
			TrayTip, Diablo IV Overlay, Showing all overlays, 2, 1
		} 
		Else If (current_window_state != 1) {
			WinMinimize, ahk_id %this_id%
			TrayTip, Diablo IV Overlay, Hdiding all overlays, 2, 1
		}
	
	}
Return




Skill1check:
if 	(sk1PixX)
	{
		CoordMode, Pizel, Screen
		PixelGetColor, sk1PixBGR, %sk1PixX%, %sk1PixY% ;get the color of the pixel where the 1st skill is
		SplitBGRColor(sk1PixBGR, Red, Green, Blue)
		if (Red > 10) or (Green > 10) or (Blue > 10)
			WinShow, OnTopReplica
		else
			WinHide, OnTopReplica
		
	}
Return

HideInactive:
if 	(sk1PixX)
{
	CoordMode, Pizel, Screen
	PixelGetColor, sk1PixBGR, %sk1PixX%, %sk1PixY% ;get the color of the pixel where the 1st skill is
	SplitBGRColor(sk1PixBGR, Red, Green, Blue)
	
	WinGet, id, list, OnTopReplica,,,
	if ((Red > 65) or (Green > 65) orR (Blue > 65)) or ((Red < 30) and (Green < 30) and (Blue < 30))
	{
		Loop, %id%
			{
				this_id := id%A_Index%
				WinGet, current_window_state, MinMax, ahk_id %this_id%,,,
				WinGetPos thisSkillX, thisSkillY, , , ahk_id %this_id%
				If (thisSkillX > 5000 ) {
					WinMove, ahk_id %this_id%, , thisSkillX - 10000, thisSkillY
				}
			}
	}
	Else 
	{
		if Red < RedMin
			RedMin := Red
		if Blue < BlueMin
			BlueMin := Blue
		if Green < GreenMin
			GreenMin := Green
		Loop, %id%
			{
				this_id := id%A_Index%
				WinGet, current_window_state, MinMax, ahk_id %this_id%,,,
				WinGetPos thisSkillX, thisSkillY, , , ahk_id %this_id%
				If (thisSkillX < 5000 ) {
					WinMove, ahk_id %this_id%, , thisSkillX + 10000, thisSkillY
				}
			}
		Loop, %id%
			{
				this_id := id%A_Index%
				WinGet, current_window_state, MinMax, ahk_id %this_id%,,,
				WinGetPos thisSkillX, thisSkillY, , , ahk_id %this_id%
				If (thisSkillX < 5000 ) {
					WinMove, ahk_id %this_id%, , thisSkillX + 10000, thisSkillY
				}
			}
	}
}
Return
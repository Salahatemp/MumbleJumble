#Include gbfscriptConfigUtilities.ahk

SetTimer, ForceExitApp, 3600000 ; 1h20 minutes

global maxAttackTurns := 999
global maxBattleNonActions := 3

Gui, Add, ListView, x6 y6 w400 h500 vLogbox LVS_REPORT, %A_Now%|Activity
 LV_ModifyCol(1, 60)
 GuiControl, -Hdr, Logbox
 Gui, Show, w410 h505, GBF Bot Log

;----------------------------------------------
;Main Loop
;----------------------------------------------

global globalTimeout := 0
global attackTurns := 0
global coopHomeCycles := 0
global resultScreenCycles := 0
global battleNonActions := 0

global waitResultMax := 2

CoordMode Pixel, Relative
CoordMode Mouse, Relative

Loop{
Sleep, % default_interval	
globalTimeout := globalTimeout + 1
updateLog("Timeout: " . globalTimeout)

;Seek browser URL
sURL := GetActiveChromeURL()
WinGetClass, sClass, A
If (sURL != "")
{
	;updateLog("The URL is : " . sURL)

	if InStr(sURL, searchBattle)
	{
		updateLog("-----In Battle-----")
		
		battleActions := [attack_button, attack_button_2]
		searchResult := multiImageSearch(coordX, coordY, battleActions)

		if(InStr(searchResult, attack_button) || InStr(searchResult, attack_button_2))
		{
				updateLog("Start Battle Sequence")

				Sleep, % default_button_delay
				RandomClickWide(attack_button_X, attack_button_Y, clickVariance)
		}
		else
		{
			updateLog("Battle action not taken, battle non action count = " . battleNonActions)
			if (battleNonActions >= maxBattleNonActions)
			{
				updateLog("Battle non action count exceeded")
				battleNonActions := 0
			}
			else
			{
				battleNonActions := battleNonActions + 1
			}
		}
	}
	else if InStr(sURL, searchResults)
	{
		updateLog("-----In Results Screen-----")
		attackTurns := 0
		globalTimeout := 0
		resultScreenCycles := resultScreenCycles + 1
		
		updateLog("Results Screen cycles: " . resultScreenCycles)		
		if(resultScreenCycles >= waitResultMax)
		{
			resultsScreenCycles := 0
			updateLog("Going to Coop Home page")
			GoToPage(coopHomeURL)
		}
		continue
	}
	
	else if InStr(sURL, searchCoopJoin)
	{
		updateLog("-----In Coop Join-----")		
	}
	else if InStr(sURL, searchCoopRoom)
	{
		updateLog("-----In Coop Room-----")
		
		coopRoomActions := [select_support, select_support_2, last_hosted, tap_start, use_item, use_item_2, not_enough_ap, not_enough_ap_2]
		searchResult := multiImageSearch(coordX, coordY, coopRoomActions)
		if searchResult = %retreat_ok%
		{
			updateLog("Retreat dialog found, clicking OK")
			RandomClick(coordX, coordY, clickVariance)
		}
		else if InStr(searchResult, select_support)
		{
			updateLog("Clicking Select Party button")
			RandomClick(select_party_button_X, select_party_button_Y, clickVariance)
			globalTimeout := 0
		}
		else if (InStr(searchResult, not_enough_ap) || InStr(searchResult, not_enough_ap_2))
		{
			updateLog("Not Enough AP dialog found, clicking Use button")
			RandomClick(coordX + 206, coordY + 490, clickVariance)
		}
		else if (InStr(searchResult, use_item) || InStr(searchResult, use_item_2)) 
		{
			updateLog("Use Item dialog found, clicking OK button")
			RandomClick(use_item_ok_X, use_item_ok_Y, clickVariance)
		}
		else if InStr(searchResult, last_hosted)
		{
			updateLog("Clicking Last Hosted button")
			RandomClick(last_hosted_X, last_hosted_Y, clickVariance)
			Sleep, % post_attack_button_delay
		}
		else if InStr(searchResult, tap_start)
		{
			updateLog("Tap Start to begin found, clicking Start")
			RandomClick(ready_button_X, ready_button_Y, clickVariance)
			Sleep, % default_interval
		}
			
		continue
	}
	else if InStr(sURL, searchCoop)
	{
		updateLog("-----In Coop Home-----")
		attackTurns := 0
		globalTimeout := 0
		
		coopHomeCycles := coopHomeCycles + 1
		updateLog("Coop Home cycles: " . coopHomeCycles)
		
		/*
		if ImageSearchWrapper(coordX, coordY, room_closed_ok)
		{
			updateLog("Clicking on room closed OK button")
			MouseMove coordX, coordY
			Click
		}
		*/
		
		if(coopHomeCycles >= waitCoopHomeMax)
		{
			coopHomeCycles := 0
			updateLog("Going to Coop Join page")
			GotoPage(coopJoinURL)
			Sleep, % default_interval
		}
		continue
	}
	else if InStr(sURL, searchSelectSummon)
	{
		updateLog("-----In Select Summon-----")
		
		selectSummonAutoSelect := [select_party_auto_select, select_party_auto_select_2, misc_icon, misc_icon_selected]
		searchResult := multiImageSearch(coordX, coordY, selectSummonAutoSelect)
		
		if InStr(searchResult, select_party_auto_select)
		{
			updateLog("Party Confirm detected, clicking OK button")
			
			RandomClick(coordX + 197, coordY + 201, clickVariance) 
			continue
		}
		else if InStr(searchResult, misc_icon)
		{
			updateLog("Clicking on summon icon")
			RandomClick(misc_summon_X, misc_summon_Y, clickVariance)
		}
		else if InStr(searchResult, wind_icon_selected)
		{
			updateLog("Clicking on first summon")
			RandomClick(first_summon_X, first_summon_Y, clickVariance) 
		}
		continue
	}
	else if InStr(sURL, mypage)
	{
		updateLog("-----In Home Page-----")
		updateLog("Going to Coop Home page")
		GoToPage(coopHomeURL)
		continue
	}
	else
	{
		updateLog("URL not identified")
		continue
	}
}
Else
	updateLog("Chrome not detected (" . sClass . ")")


}

Return



;----------------------------------------------
;Keybinds
;----------------------------------------------

F1::
updateLog("Resizing window to " . GBF_winWidth . " x " . GBF_winHeight)
ResizeWin(GBF_winWidth, GBF_winHeight)
Return

F12::Pause

GuiClose:
ExitApp

Esc::
ExitApp

ForceExitApp:
SetTimer,  ForceExitApp, Off
ExitApp





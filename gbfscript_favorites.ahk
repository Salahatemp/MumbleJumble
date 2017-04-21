#Include gbfscriptConfigUtilities.ahk

SetTimer, ForceExitApp, 3600000 ; 1h20 minutes

global maxAttackTurns := 999
global maxBattleNonActions := 2
global maxBattles := 10

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
global battleCount := 0
global maxBattles := maxBattles * waitResultMax

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

	if InStr(sURL, searchStage)
	{
		updateLog("-----In Stage-----")
		RandomClick(stage_ok_X, stage_ok_Y1, clickVariance)
		Sleep, % default_interval 
		RandomClick(stage_ok_X, stage_ok_Y2, clickVariance)
		Sleep, % default_interval 
		continue
	}
	if InStr(sURL, searchBattle)
	{
		updateLog("-----In Battle-----")
		
		battleActions := [attack_button, attack_button_2]
		searchResult := multiImageSearch(coordX, coordY, battleActions)

		if InStr(searchResult, attack_button)
		{
				updateLog("Start Battle Sequence")
				
				;ClickSkill(1, 2)
				;ClickSkill(1, 3)
				ClickSkill(1, 4)
				
				Sleep, % default_button_delay
				RandomClickWide(attack_button_X, attack_button_Y, clickVariance)			
		}
		else
		{
			updateLog("Battle action not taken, battle non action count = " . battleNonActions)
			if (battleNonActions >= maxBattleNonActions)
			{
				updateLog("Battle non action count exceeded, clicking Next button")
				battleNonActions := 0

				RandomClick(next_button_X, next_button_Y, clickVariance)
			}
			else
			{
				battleNonActions := battleNonActions + 1
			}
		}
		continue
	}
	else if InStr(sURL, searchResults)
	{
		updateLog("-----In Results Screen-----")
		attackTurns := 0
		globalTimeout := 0
		battleNonActions := 0
		
		battleCount := battleCount + 1
		updateLog("Battle count: " . battleCount)
		if(battleCount >= maxBattles)
		{
			MsgBox, 4,, Max battles reached - continue?
			IfMsgBox Yes
				battleCount := 0
			else
				ExitApp
		}
		
		resultScreenCycles := resultScreenCycles + 1
		
		updateLog("Results Screen cycles: " . resultScreenCycles)		
		if(resultScreenCycles >= waitResultMax)
		{
			resultsScreenCycles := 0
			updateLog("Going to Quests page")
			GoToPage(questURL)
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
	
	}
	else if InStr(sURL, searchCoop)
	{
		updateLog("-----In Coop Home-----")
	}
	else if InStr(sURL, searchSelectSummon)
	{
		updateLog("-----In Select Summon-----")
		
		selectSummonAutoSelect := [select_party_auto_select, select_party_auto_select_2, special_members, misc_icon, misc_icon_selected]
		searchResult := multiImageSearch(coordX, coordY, selectSummonAutoSelect)
		
		if InStr(searchResult, select_party_auto_select)
		{
			updateLog("Party Confirm detected, clicking OK button")
			
			RandomClick(coordX + 197, coordY + 201, clickVariance) 
			continue
		}
		else if InStr(searchResult, special_members)
		{
			updateLog("Special Member dialog found, clicking OK button")
			RandomClick(select_summon_ok_X, select_summon_ok_Y, clickVariance)
		}
		else if InStr(searchResult, misc_icon)
		{
			updateLog("Clicking on summon icon")
			RandomClick(misc_summon_X, misc_summon_Y, clickVariance)
		}
		else if InStr(searchResult, misc_icon_selected)
		{
			updateLog("Clicking on first summon")
			RandomClick(first_summon_X, first_summon_Y, clickVariance) 
		}
		continue
	}
	else if InStr(sURL, searchQuest)
	{
		updateLog("-----In Quests Screen-----")
		
		questActions := [view_story, use_item, not_enough_ap, favorites_button, featured_button]
		searchResult := multiImageSearch(coordX, coordY, questActions)
		
		if InStr(searchResult, favorites_button)
		{
			updateLog("Favorites button found, clicking")
			RandomClick(favorites_button_X, favorites_button_Y, clickVariance)
			Sleep, % default_interval  * 3
		}
		else if InStr(searchResult, featured_button)
		{
			updateLog("Featured button found, clicking on first favorite")
			RandomClick(first_favorite_X, first_favorite_Y, clickVariance)
			Sleep, % default_interval  * 3
		}
		else if InStr(searchResult, not_enough_ap)
		{
			updateLog("Not Enough AP dialog found, clicking Use button")
			RandomClick(coordX + 206, coordY + 490, clickVariance)
		}
		else if InStr(searchResult, use_item)
		{
			updateLog("Use Item dialog found, clicking OK button")
			RandomClick(use_item_ok_X, use_item_ok_Y, clickVariance)
		}
		else if InStr(searchResult, view_story)
		{
			updateLog("Story dialog found, clicking episode")
			RandomClick(story_X, story_4_Y, clickVariance)	
			Sleep, % default_interval * 2
			RandomClick(story_ok_X, story_ok_Y-75, clickVariance)	
			Sleep, % default_interval 	
			RandomClick(story_ok_X, story_ok_Y-50, clickVariance)	
			Sleep, % default_interval 	
			RandomClick(story_ok_X, story_ok_Y-25, clickVariance)	
			Sleep, % default_interval 	
			RandomClick(story_ok_X, story_ok_Y, clickVariance)	
			Sleep, % default_interval 			
		}

		continue
	}	
	else if InStr(sURL, mypage)
	{
		updateLog("-----In Home Page-----")
		updateLog("Going to Quest page")
		GoToPage(questURL)
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


' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

sub ShowDetailsScreen(content as Object, selectedItem as Integer)
    ' create new instance of details screen
    detailsScreen = CreateObject("roSGNode", "DetailsScreen")
    detailsScreen.content = content
    detailsScreen.jumpToItem = selectedItem ' set index of item which should be focused
    detailsScreen.ObserveField("visible", "OnDetailsScreenVisibilityChanged")
    detailsScreen.ObserveField("buttonSelected", "OnButtonSelected")
    ShowScreen(detailsScreen)
end sub

sub OnDetailsScreenVisibilityChanged(event as Object) ' invoked when DetailsScreen "visible" field is changed
    visible = event.GetData()
    detailsScreen = event.GetRoSGNode()
    currentScreen = GetCurrentScreen()
    screenType = currentScreen.SubType()
    if visible = false
        if screenType = "GridScreen"
            ' update GridScreen's focus when navigate back from DetailsScreen
            currentScreen.jumpToRowItem = [m.selectedIndex[0], detailsScreen.itemFocused]
        else if screenType = "EpisodesScreen"
            ' update EpisodesScreen's focus when navigate back from DetailsScreen
            content = detailsScreen.content.GetChild(detailsScreen.itemFocused)
            currentScreen.jumpToItem = content.numEpisodes
        end if
    end if
end sub

sub OnButtonSelected(event) ' invoked when button in DetailsScreen is pressed
    details = event.GetRoSGNode()
    content = details.content
    buttonIndex = event.getData() ' index of selected button
    selectedItem = details.itemFocused
    if buttonIndex = 0 ' check if "Play" button is pressed
        ' create Video node and start playback
        HandlePlayButton(content, selectedItem)
    else if buttonIndex = 1 ' check if "See all episodes" button is pressed
        ' create EpisodesScreen instance and show it
        ShowVideoScreen()
    end if
end sub

sub HandlePlayButton(content as Object, selectedItem as Integer)
    itemContent = content.GetChild(selectedItem)

    CheckSubscriptionAndStartPlayback(content, selectedItem)
    ' cur = m.sec.read("current")
    ' print "cur : ", m.sec.read("current")
    ' ' m.sec.write("next", cur)



    ' if m.sec.read("next") <> invalid

    '     nex = m.sec.read("next")
    '     print " nex = ", nex
    '     if cur <> nex

    '         ShowVideoScreen()
    
    '     else
            
    
    '     end if
    ' else
    '     m.sec.write("next", str(cur))
    ' endif

    

    m.selectedIndex[1] = selectedItem ' store index of selected item
end sub
sub Init()
    ' set background color for scene. Applied only if backgroundUri has empty value
    m.top.backgroundColor = "0x662D91"
    m.top.backgroundUri= "pkg:/images/background.jpg"
    m.loadingIndicator = m.top.FindNode("loadingIndicator") ' store loadingIndicator node to m
    InitScreenStack()
    ShowKeyboardScreen()
    ' to handle Roku Pay we need to create channelStore object in the global node

    m.global.AddField("channelStore", "node", false)
    m.global.channelStore = CreateObject("roSGNode", "ChannelStore")

    ' =======================================================

    date_time = CreateObject("roDateTime")


    m.sec = CreateObject("roRegistrySection", "date_time")

    


    m.current_week_day = date_time.GetDayOfMonth() 
    m.current_month = date_time.GetMonth()




    m.sec.write("current", str(m.current_week_day))
    ' m.sec.write("next", str(m.current_week_day))

end sub

function OnkeyEvent(key as String, press as Boolean) as Boolean
   

    result = false
    if press
        if key = "back"
            ' m.loadingIndicator.visible = false
            numberOfScreens = m.screenStack.Count()
            if numberOfScreens > 1
                CloseScreen(invalid)
                result = true
            end if
        end if
    end if
    return result
end function

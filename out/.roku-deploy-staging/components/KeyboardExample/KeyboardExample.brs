sub init()
    print "  ************  Init method of keyboard example called  ************  "
    'm.top.backgroundURI = "pkg:/images/rsgde_bg_hd.jpg"
    m.myKeyboard = m.top.findNode("KeyboardExample")
    m.myButton = m.top.findNode("exampleButton")

    examplerect = m.myKeyboard.boundingRect()
    centerx = (1280 - examplerect.width) / 2
    centery = (720 - examplerect.height) / 2
    m.myKeyboard.translation = [ centerx, centery ]

    m.top.setFocus(true)
    m.myButton.ObserveField("buttonSelected", "onButtonClicked")
end sub


sub onButtonClicked()
    m.top.userTyped = m.myKeyboard.text
    print " ************ Keyboard values : ", m.myKeyboard.text
    WriteAsciiFile("tmp:/config.txt", m.myKeyboard.text)

end sub

function onKeyEvent(key as String, press as boolean) as boolean

    result =  false
    if press then 
        if key = "down"
            m.myButton.setFocus(true)
            result = true'
        else if key = "up"
            m.myKeyboard.setFocus(true)
            result = true
        end if
    end if

    return result
    
end function

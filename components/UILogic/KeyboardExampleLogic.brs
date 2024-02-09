sub ShowKeyboardScreen()

    m.KeyboardScreen = CreateObject("roSGNode", "KeyboardExample")
    ShowScreen(m.KeyboardScreen)
    m.KeyboardScreen.ObserveField("userTyped", "DisplayNewScreen")
    ' m.KeyboardScreen.content = m.KeyboardScreen.userTyped
end sub

sub DisplayNewScreen()

    ShowGridScreen()
    RunContentTask()
end sub
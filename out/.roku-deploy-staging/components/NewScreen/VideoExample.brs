
sub init()
    ? "****************** INIT OF VID EXAMPLE CALLED"
 
    m.video = m.top.findNode("exampleVideo")
    ' videoContent = createObject("RoSGNode", "ContentNode")
    ' videoContent.url = "https://roku.s.cpl.delvenetworks.com/media/59021fabe3b645968e382ac726cd6c7b/60b4a471ffb74809beb2f7d5a15b3193/roku_ep_111_segment_1_final-cc_mix_033015-a7ec8a288c4bcec001c118181c668de321108861.m3u8"
    ' videoContent.title = "Test Video"
    ' videoContent.streamformat = "hls"
  
    ' 'm.video = m.top.findNode("musicvideos")
    ' m.video.content = videoContent
    ' m.video.control = "play"
    m.ContentNode = createObject("roSGNode", "ContentNode")
    text2 = ReadAsciiFile("tmp:/video_title.txt")
    print "Video Title : "; text2
    m.ContentNode.title = text2
    m.ContentNode.streamformat = "mp4"
    text1 = ReadAsciiFile("tmp:/video_id.txt")
    'm.ContentNode.url = "https://kidstube.invotyx.com/api/v2/video/?video_id="+ text1 +""
    m.ContentNode.url = "https://invidious.fdn.fr/latest_version?id="+ text1 +"&itag=22&local=true"

    print "url :::: " m.ContentNode.url
    m.video.content = m.ContentNode
    m.video.control = "play"
    m.video.visible = true

    ' print "video : ", m.video

    m.video.setFocus(true)

end sub


' function onKeyEvent(key as String,press as Boolean) as Boolean

'     if press then
'         if key = "right"

'             posit = m.video.position
'             print "Position : "; posit
'             m.video.seek += 5
'         elseif key = "left"

'             posit = m.video.position
'             print "Position : "; posit
'             m.video.seek -= 5
'         end if
'     end if
' end function
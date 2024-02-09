sub Init()
    ' Set the name of the function in the Task node component to be executed when the state field changes to RUN
    ' In our case, this method is executed after the following command: m.contentTask.control = "run" (see Init method in MainScene)
    m.top.functionName = "GetContent"
end sub

sub GetContent()
    ' Request the content feed from the API
    xfer = CreateObject("roURLTransfer")
    xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")

    ' Read content from a file (you might want to adjust the path or filename)
    text = ReadAsciiFile("tmp:/config.txt")

    if Len(text) > 0
        ' Use roUrlTransfer's UrlEncode function to sanitize the URL parameter
        sanitizedText = CreateObject("roUrlTransfer").UrlEncode(text)

        ' Construct the URL with the variable
        url = "https://kidstube.invotyx.com/api/v2/videos/search/?title=" + sanitizedText + "&page=1"

        ' Use the URL in your API request
        xfer.SetURL(url)
        ' print "URL: " + url

        ' Perform the API request
        responseString = xfer.GetToString()
        ' print "Response: " + responseString
    else
        print "Error: The content of the file is empty."
        return
    end if

    ' Parse the feed and build a tree of ContentNodes to populate the GridView
    json = ParseJson(responseString)

    ' Initialize the response array
    responseArray = []

    if json <> invalid
        for each category in json
            value = json.Lookup(category)
            if Type(value) = "roArray" and category <> "series"
                row = {}
                row.title = category
                row.children = []

                row2 = {}
                row2.children = []

                for each item in value
                    if row.children.count() < 20
                        itemData = GetItemData(item)
                        ' Append the item data to the children array
                        row.children.Push(itemData)
                    else 
                        itemData = GetItemData(item)
                        ' Append the item data to the children array
                        row2.children.Push(itemData)
                    end if

                end for

                ' Append the row to the root array
                responseArray.Push(row)
                responseArray.Push(row2)
            end if
        end for

        ' Set up a root ContentNode to represent rowList on the GridScreen
        contentNode = CreateObject("roSGNode", "ContentNode")
        contentNode.Update({
            children: responseArray ' Use the responseArray as the children
        }, true)

        ' Populate content field with the root content node
        ' Observer (see OnMainContentLoaded in MainScene.brs) is invoked at that moment
        m.top.content = contentNode
    end if
end sub

function GetItemData(video as Object) as Object
    item = {}
    ' Populate some standard content metadata fields to be displayed on the GridScreen
    ' https://developer.roku.com/docs/developer-program/getting-started/architecture/content-metadata.md
    if video.longDescription <> invalid
        item.description = video.longDescription
    else
        item.description = video.shortDescription
    end if

    item.hdPosterURL = video.thumbnail
    item.title = video.title
    item.thumbnail = video.thumbnail
    item.published_at = video.published_at
    item.video_url = video.video_url
    item.video_id = video.video_id
    item.s3_url = video.s3_url
    item.is_audio = video.is_audio
    item.view_count = video.view_count


    
    

    if video.content <> invalid
        ' Populate length of content to be displayed on the GridScreen
        item.length = video.content.duration
        ' Populate meta-data for playback
        item.url = video.content.videos[0].url
        item.streamFormat = video.content.videos[0].videoType
    end if
  

    return item
end function

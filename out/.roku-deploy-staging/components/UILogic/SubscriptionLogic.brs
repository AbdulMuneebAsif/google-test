sub CheckSubscriptionAndStartPlayback(rowContent as Object, selectedItem = 0 as Integer, isSeries = false as Boolean)
    m.rowContent = rowContent
    m.selectedItem = selectedItem
    m.isSeries = isSeries

    m.cur = m.sec.read("current")
    print "cur : ", m.sec.read("current")
    ' m.sec.write("next", m.cur)
    

    if RegRead("next") <> invalid
        print "if m.sec.read(next) <> invalid"
        nex = m.sec.read("next")
        print " nex = ", nex

        if str(m.current_week_day) <> nex 
            print "if str(m.current_week_day) <> nex "
            ShowVideoScreen()
        else           
            print "RunSubscriptionFlow()    m.update_next = m.cur.toInt() + 1"
            RunSubscriptionFlow()
            m.update_next = m.cur.toInt() + 1
            m.sec.write("next", str(m.update_next))

            print "m.update_next = ", m.update_next

        end if

    else
        print "RunSubscriptionFlow()"
        m.sec.write("next", str(m.current_week_day))

        RunSubscriptionFlow()
        print "next = ", m.current_week_day

        
    endif

    
end sub

sub RunSubscriptionFlow()
    ' flag needed to show the trial for a new user
    m.isProductWithExpiredTrial = false

    ' show a progressive dialog while retrieving an user's purchases
    dialogCheckSubs = CreateObject("roSGNode", "ProgressDialog")
    dialogCheckSubs.title = "Checking subscriptions..."
    ' to show a dialog set it to the interface field of MainScene
    m.top.dialog = dialogCheckSubs

    ' retrieve purchases by calling channelStore command
    m.global.channelStore.command = "getPurchases"
    ' set an observer to be able to handle actions once loaded
    m.global.channelStore.ObserveField("purchases", "OnGetPurchases")
    ' read_crrent_date = ReadAsciiFile("tmp:/currentDate.txt")
    ' print "Current Date = > "; read_crrent_date
end sub

sub OnGetPurchases(event as Object)
    m.global.channelStore.UnobserveField("purchases")
    purchases = event.GetData() ' extract loaded purchases

    ' check if dialog hasn't been closed before by a user
    if m.top.dialog <> invalid
        m.top.dialog.close = true   ' close previous dialog
    else
        return
    end if

    ' purchases are appended as children, so we need to check if there are some
    if purchases.GetChildCount() > 0
        ' there are some subscriptions

        ' check if there are some active subscriptions among the purchases
        allPurchases = purchases.GetChildren(-1, 0)

        ' retrieve current time in seconds
        datetime = CreateObject("roDateTime")
        utimeNow = datetime.AsSeconds()

        ' check expiration date of each purchased subscription
        for each purchase in allPurchases

            datetime.FromISO8601String(purchase.expirationDate)

            utimeExpire = datetime.AsSeconds()

            ' if user has active subscription then show content
            ' otherwise navigate to purchase option
            if utimeExpire > utimeNow
                ' m.update_next = m.cur.toInt() + 1

                ' the entire row from the RowList will be used by the Video node
                ShowVideoScreen()
                ' m.sec.write("next", str(m.update_next))

                return
            else
                ' if user already has expired trial subscription then we need to
                ' show catalog without trial option
                if purchase.freeTrialQuantity > 0
                    m.isProductWithExpiredTrial = true
                end if
            end if
        end for
    end if

    ' no subscription at all, thus show catalog to get one

    ' show a progressive dialog while retrieving a catalog
    dialogCheckProducts = CreateObject("roSGNode", "ProgressDialog")
    dialogCheckProducts.title = "Retrieving available products..."
    m.top.dialog = dialogCheckProducts  ' set dialog to MainScene

    ' retrieve a catalog by calling channelStore command
    m.global.channelStore.command = "getCatalog"
    ' set an observer to be able to handle actions once loaded
    m.global.channelStore.ObserveField("catalog", "OnGetCatalog")
end sub

sub OnGetCatalog(event as Object)
    m.global.channelStore.UnobserveField("catalog")
    catalog = event.GetData()   ' extract loaded catalog
    ' check if dialog hasn't been closed before by a user
    if m.top.dialog <> invalid
        m.top.dialog.close = true   ' close previous dialog
    else
        return
    end if

    dialog = CreateObject("roSGNode", "Dialog")

    ' catalog items are appended as children, so we need to check if there are some
    if catalog.GetChildCount() > 0
        ' there are some available subscription to get
        dialog.title = "Subscriptions"
        dialog.message = "Please select subscription type:"

        ' create buttons on dialog with products info
        ' to create buttons we need to create an array of strings
        subscriptions = []
        m.activeCatalogItems = []
        print "1 ) ", subscriptions
        for each product in catalog.GetChildren(-1, 0)
            print "2 ) ", m.activeCatalogItems     
            m.isProductWithExpiredTrial = true
            print "m.isProductWithExpiredTrial = ", m.isProductWithExpiredTrial 
            if m.isProductWithExpiredTrial ' if trial has been already used
                print "3) ", subscriptions, m.activeCatalogItems 
                ' then show only products without trial
                if product.freeTrialQuantity = 0
                    subscriptions.Push(product.name + " " + product.cost)
                    m.activeCatalogItems.Push({
                        code: product.code,
                        name: product.name
                    })

                    
                end if
            else     ' if trial hasn't been already used
                ' then show only products with trial
                if product.freeTrialQuantity > 0
                    subscriptions.Push(product.name + " " + product.cost)
                    m.activeCatalogItems.Push({
                        code: product.code,
                        name: product.name
                    })
                end if
            end if
        end for

        dialog.buttons = subscriptions  ' set buttons to dialog field
        ' set an observer to handle actions on button press
        dialog.ObserveField("buttonSelected", "DoSubscriptionOrder")
    else
        ' no available subscription to get some
        dialog.title = "Error"
        dialog.message = "There are not any available subscriptions for now..."
    end if

    m.top.dialog = dialog   ' Set dialog to MainScene
end sub

' handle button press on purchase dialog
sub DoSubscriptionOrder(event as Object)
    ' extract buttonSelected index from the dialog
    buttonSelectedIndex = m.top.dialog.buttonSelected
    ' extract catalog item as child by index from the channelStore node
    catalogItem = m.activeCatalogItems[buttonSelectedIndex]

    ' to create an order we need to create a ContentNode with children as products to purchase
    order = CreateObject("roSGNode", "ContentNode")
    product = order.CreateChild("ContentNode")
    ' also we need to set required info as code, name and quantity
    product.AddFields({ code: catalogItem.code, name: catalogItem.name, qty: 1 })

    ' do an order by setting order to channelStore field and calling its command
    m.global.channelStore.order = order
    m.global.channelStore.command = "doOrder"
    ' observe orderStatus to be able to handle order response
    m.global.channelStore.ObserveField("orderStatus", "OnOrderStatus")
end sub

sub OnOrderStatus(event as Object)
    orderStatus = event.GetData()
    if orderStatus <> invalid and orderStatus.status = 1
        ' if order has been processed successfully then show
        
        ' m.update_next = m.cur.toInt() + 1
        ShowVideoScreen()
        ' m.sec.write("next", str(m.update_next))

    else
        ' otherwise show error dialog
        dialog = CreateObject("roSGNode", "Dialog")
        dialog.title = "Error"
        dialog.message = "Failed to process your payment. Please try again."
        m.top.dialog = dialog
    end if
    m.global.channelStore.UnobserveField("orderStatus")
end sub

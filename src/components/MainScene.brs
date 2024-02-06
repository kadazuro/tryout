sub init()
    m.buttonGroup = m.top.findNode("buttonGroup")
    m.buttonGroup.buttons = ["Launch preferences for a Virginia resident", "Launch preferences for a Florida resident"]
    m.buttonGroup.observeField("buttonSelected", "onButtonSelected")
    buttonRect = m.buttonGroup.boundingRect()
    centerx = (1920 - buttonRect.width) / 2
    centery = (1080 - buttonRect.height) / 2
    m.buttonGroup.translation = [centerx, centery]
    m.buttonGroup.setFocus(true)

    m.preferencesGroup = m.top.findNode("preferencesGroup")
    m.checkList = m.top.findNode("checkList")
    m.checkList.checkedState = [true, false]
    centerx = (1920 - 1000) / 2
    centery = (1080 - 400) / 2
    m.preferencesGroup.translation = [centerx, centery]
    'm.top.setFocus(true)

    m.saveButton = m.top.findNode("saveButton")
    m.saveButton.observeField("buttonSelected", "onSaveButtonSelected")
    m.cancelButton = m.top.findNode("cancelButton")
    m.cancelButton.observeField("buttonSelected", "onCancelButtonSelected")

    m.spinner = m.top.findNode("spinner")
    m.spinner.poster.uri = "pkg:/images/loading.png"

    m.disabledLabel = m.top.findNode("disabledLabel")

end sub


sub onButtonSelected()

    if m.consent <> invalid
        m.consent.unObserveField("initializeReady")
        m.consent = invalid
    end if

    m.consent = createObject("roSGNode", "Consent")
    m.consent.observeField("initializeReady", "onInitializeReady")

    selection = m.buttonGroup.buttonSelected
    if selection = 1
        m.consent.callFunc("initialize", { location: "FL" })
    else
        m.consent.callFunc("initialize", { location: "VA" })
    end if

end sub

sub onInitializeReady()
    print("on init ready")
    user = m.consent.callFunc("getUser")

    'update settings.
    m.canUserChangeSettings = m.consent.callFunc("canUserChangeSettings")
    m.disabledLabel.visible = not m.canUserChangeSettings
    m.checkList.checkOnSelect = m.canUserChangeSettings
    m.saveButton.visible = m.canUserChangeSettings

    m.checkList.checkedState = [converStringToBoolean(user.dataCollection), converStringToBoolean(user.dataSharing)]
    m.preferencesGroup.visible = true
    m.buttonGroup.visible = false
    m.checkList.jumpToItem = 0
    m.checkList.setFocus(true)
end sub


function converStringToBoolean(value as string) as boolean
    return value = "true"
end function


function convertBooleanToString(value as boolean) as string
    if value = true
        return "true"
    else
        return "false"
    end if
end function

sub onCheckListSelected()

end sub

function onKeyEvent(key as string, press as boolean) as boolean
    handled = false
    if press
        if key = "down" and m.checkList.hasFocus() and m.checkList.itemFocused = 1 and m.canUserChangeSettings
            m.saveButton.setFocus(true)
            handled = true
        end if

        if key = "down" and m.checkList.hasFocus() and m.checkList.itemFocused = 1 and not m.canUserChangeSettings
            m.cancelButton.setFocus(true)
            handled = true
        end if

        if key = "up" and m.saveButton.hasFocus()
            m.checkList.setFocus(true)
            handled = true
        end if

        if key = "up" and m.cancelButton.hasFocus()
            m.checkList.setFocus(true)
            handled = true
        end if

        if key = "right" and m.saveButton.hasFocus()
            m.cancelButton.setFocus(true)
            handled = true
        end if

        if key = "left" and m.cancelButton.hasFocus() and m.canUserChangeSettings
            m.saveButton.setFocus(true)
            handled = true
        end if

    end if
    return handled
end function

sub onSaveButtonSelected()
    showConfirmationDialog()
end sub

sub onCancelButtonSelected()
    resetView()
end sub

sub showConfirmationDialog()
    m.confirmationDialog = createObject("roSGNode", "StandardMessageDialog")
    m.confirmationDialog.title = "Update changes"
    m.confirmationDialog.message = ["Do you wan to save the changes?"]
    m.confirmationDialog.Buttons = ["Cancel", "Save"]
    m.confirmationDialog.observeFieldScoped("wasClosed", "onDialogClosed")
    m.confirmationDialog.observeFieldScoped("buttonSelected", "dismissDialog")
    m.top.dialog = m.confirmationDialog
end sub

sub onDialogClosed()

end sub

sub dismissDialog()
    if m.confirmationDialog.buttonSelected = 1
        dataCollection = convertBooleanToString(m.checkList.checkedState[0])
        dataSharing = convertBooleanToString(m.checkList.checkedState[1])
        'save changes
        m.consent.callFunc("updateSettings", dataCollection, dataSharing)
        'reset view
        resetView()
    else
        onInitializeReady()
    end if
    m.confirmationDialog.close = true
end sub

sub resetView()
    m.preferencesGroup.visible = false
    m.buttonGroup.visible = true
    m.buttonGroup.setFocus(true)
end sub



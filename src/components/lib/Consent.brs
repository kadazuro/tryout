sub init()
    m.registryKey = "consent"
    m.dataKeys = ["userId", "location", "dataCollection", "dataSharing"]
    m.enabledStates = ["CA", "CO", "CT", "VA"]
    m.dataCollectionKey = "dataCollection"
    m.dataSharingKey = "dataSharing"
end sub

sub initialize(params as object)
    appInfo = CreateObject("roAppInfo")
    'kludge update registrykey to make values unique per location
    m.registryKey = params.location + "consent"
    registry = getRegistry()
    if registry.exists(m.dataKeys[0])
        readUserInfo()
    else
        createUser(params)
    end if
end sub

function getUser() as object
    if m.user <> invalid
        return m.user
    end if
end function

function canUserChangeSettings() as boolean
    location = m.user.location
    found = false
    for i = 0 to m.enabledStates.count()
        if location = m.enabledStates[i]
            print("found")
            found = true
            exit for
        end if
    end for
    return found
end function

sub updateSettings(dataCollection as string, dataSharing as string)
    user = m.user
    user.dataCollection = dataCollection
    user.dataSharing = dataSharing
    save(user)
end sub


sub createUser(params as object)
    deviceInfo = CreateObject("roDeviceInfo")

    user = createObject("roSGNode", "User")
    user.userId = deviceInfo.GetChannelClientId()
    user.location = UCase(params.location)
    user.dataCollection = "true"
    user.dataSharing = "true"
    save(user)
    m.top.initializeReady = true
end sub

sub readUserInfo()
    registry = getRegistry()
    user = registry.readMulti(m.dataKeys)
    m.user = createObject("roSGNode", "User")
    for each key in m.dataKeys
        m.user[key] = user[key]
    end for
    m.top.initializeReady = true
end sub


function getRegistry() as object
    return CreateObject("roRegistrySection", m.registryKey)
end function

sub save(user as object)
    registry = getRegistry()
    values = {}
    for each key in m.dataKeys
        values[key] = user[key]
    end for
    registry.WriteMulti(values)
    m.user = user
end sub
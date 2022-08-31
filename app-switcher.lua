local this = {}
this.logger = hs.logger.new('app-switcher','info')
this.lastApp = nil
this.lastWindowId = nil

-- Alert function
this.alert = function(message)
    style = {
        strokeColor = {white = 1, alpha = 0},
        fillColor = {white = 0.05, alpha = 0.75},
        radius = 10
    }
    hs.alert.closeAll(0)
    hs.alert.show(message, style, 3)
end

-- Move to given window and center mouse on it
this.moveToWindow = function(win)
    win:focus()
    center = hs.geometry.rectMidPoint(win:frame())
    hs.mouse.absolutePosition(center)
    this.lastWindowId = win:id()
end

this.cycleWindows = function(appWindows)
    local idToWindow = {}
    local idsList = {}
    local nextWindow = nil
    for _, win in pairs(appWindows) do
        idToWindow[win:id()] = win
        table.insert(idsList, win:id())
    end
    table.sort(idsList)

    local lastWindow = idToWindow[this.lastWindowId]
    -- Last window no longer exists, maybe closed. Then just open first window from the list
    if lastWindow == nil then
        this.logger:i('Last window not found opens random window')
        nextWindow = appWindows[1]
    -- Last window exists
    else
        -- If not focused then focus on it
        if hs.window.focusedWindow() ~= lastWindow then
            this.logger:i('Last window not focused, focus on it')
            nextWindow = lastWindow
        -- Find next window in order
        else
            -- Find the index of the last window
            local idIndex = 1
            for index, winid in ipairs(idsList) do
                if winid == this.lastWindowId then
                    idIndex = index
                    break
                end
            end

            -- Get next index in cyclic way
            this.logger:i('Switch to next window')
            nextIndex = (idIndex % #idsList) + 1
            nextWindow = idToWindow[idsList[nextIndex]]
        end
    end

    this.moveToWindow(nextWindow)
end

this.openApp = function(appName, launchName)
    local name = launchName or appName
    this.logger:i('Launch ' .. name)
    this.alert('Launch ' .. name)
    local launched = hs.application.launchOrFocus(name)
    if launched then
        local app = hs.application.find(name)
        this.moveToWindow(app:focusedWindow())
    end
end

this.handleApp = function(appName, launchName)
    local app = hs.application.find(appName)
    -- If app is closed, open it
    if app == nil then
        this.openApp(appName, launchName)
    else
        -- Load all the app current open windows
        local appWindows = hs.fnutils.ifilter(app:allWindows(), function(w)
            return w:isStandard()
        end)
        if #appWindows == 0 then
            this.openApp(appName, launchName)
        elseif this.lastApp == appName then
            this.logger:i('Cycle ' .. appName)
            this.cycleWindows(appWindows)
        else
            this.logger:i('Move to ' .. appName)
            this.moveToWindow(appWindows[1])
        end
    end

    this.lastApp = appName
end


-- Init of application map
this.init = function(switcherMap, windowLaunchMap, hyperKey)
    -- set up the binding for each key combo
    for key, appName in pairs(switcherMap) do
        hyperKey:bind({}, key, function()
            this.handleApp(appName, windowLaunchMap[key])
        end)
    end
end

return this

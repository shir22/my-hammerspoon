hyper = require('hyper')
appSwitcher = require('app-switcher')
winwin = hs.loadSpoon('WinWin')
logger = hs.logger.new('init.lua','info')

-- shortcut for sleep
hyper:bind({"cmd"}, "s", function()
  hs.caffeinate.systemSleep()
end)

function windowResizeFrames(dir, screen)
  local cres = screen:fullFrame()
  local topbar_diff = cres.h - screen:frame().h
  if dir == 'left' then
    return {x=cres.x, y=cres.y + topbar_diff, w=cres.w/2, h=cres.h - topbar_diff}
  elseif dir == 'right' then
    return {x=cres.x+cres.w/2, y=cres.y + topbar_diff, w=cres.w/2, h=cres.h - topbar_diff}
  elseif dir == 'down' then
    return {x=cres.x, y=cres.y+cres.h/2, w=cres.w, h=cres.h/2}
  end
end

-- shortcut for window resize
hyper:bind({}, "right", function()
  local cwin = hs.window.focusedWindow()
  if cwin then
      local cscreen = cwin:screen()
      local wf = cwin:frame()
      local geo = windowResizeFrames('right', cscreen)
      if wf:floor():equals(geo) then
        cwin:setFrame(windowResizeFrames('left', cscreen:next()))
      else
        cwin:setFrame(geo)
      end
  end
end)
hyper:bind({}, "left", function()
  local cwin = hs.window.focusedWindow()
  if cwin then
      local cscreen = cwin:screen()
      local wf = cwin:frame()
      local geo = windowResizeFrames('left', cscreen)
      if wf:floor():equals(geo) then
        cwin:setFrame(windowResizeFrames('right', cscreen:previous()))
      else
        cwin:setFrame(geo)
      end
  end
end)
hyper:bind({}, "up", function() winwin:moveAndResize('maximize') end)
hyper:bind({}, 'down',  function() winwin:moveAndResize('halfdown') end, nil, function() winwin:moveAndResize('halfup') end)
hyper:bind({}, "return", function() hs.window.focusedWindow():toggleFullScreen() end)
hyper:bind({"cmd"}, "left", function()
  -- get the focused window
  local win = hs.window.focusedWindow()
  -- get the screen where the focused window is displayed, a.k.a. current screen
  local screen = win:screen()
  -- compute the unitRect of the focused window relative to the current screen
  -- and move the window to the next screen setting the same unitRect
  win:move(win:frame():toUnitRect(screen:frame()), screen:previous(), true, 0)
end)
hyper:bind({"cmd"}, "right", function() winwin:moveToScreen('right') end)

-- shortcut to show desktop
hyper:bind({}, "delete", function()
  local app = hs.application.find('Finder')
  app:activate()
  app:selectMenuItem('Hide Others')
end)

-- Shortcuts for fast app switching
local switcherMap = {
  a = "Whatsapp",
  b = "Adobe Acrobat",
  c = "Google Chrome",
  d = "Preview",
  f = "Finder",
  g = "Mail",
  i = "iTerm",
  m = "Spotify",
  p = "Microsoft Powerpoint",
  s = "Slack",
  t = "Microsoft To Do",
  v = "Code",
  w = "Microsoft Word",
  x = "Microsoft Excel",
  y = "PyCharm",
  z = "zoom.us",
}

-- if the app has to be launched by a different name than the one the windows are found by, this list
-- will take precedence when opening the app.
local switcherLaunchMap = {
  v = "Visual Studio Code"
}

appSwitcher.init(switcherMap, switcherLaunchMap, hyper)

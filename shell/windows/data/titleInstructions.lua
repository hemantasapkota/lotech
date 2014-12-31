local lyr = lt.Layer()

lyr:Insert(import "titleFrame")

local l, r, t, b = lt.config.world_left, lt.config.world_right, lt.config.world_top, lt.config.world_bottom

lyr:Insert(lt.Rect(l, b, r, t):Tint(0, 0, 0, .40))

local pnl  = lt.Layer()

local hdr  = panel_header("INFO", -1.2, 1.2)
local body = panel_body(0.3, -0.5)

body:Insert(_txt_base2("PLEASE USE CURSOR KEYS\n FOR NAVIGATION."):Scale(config.pnl_title_scl))

local action_lbl = "ENTER"

body:Insert(make_action_bars({action_lbl}):Translate(0, -0.3))

action_bars[action_lbl].select = true
action_bars[action_lbl].action = function()
  main_scene:Remove(lyr)
  import "title"
end

pnl:Insert(hdr)
pnl:Insert(body)

lyr:Insert(pnl:Translate(0, 2):Tween{x=0, y=0.3, time=0.3, easing="zoomin"})

lyr:KeyDown(function(event)
  if event.key == "enter" or event.key == "esc" then
    action_bars[action_lbl].action()
  end
end)

--override title's pointer down event
lyr:PointerDown(function(event)
end)

main_scene:Insert(lyr)

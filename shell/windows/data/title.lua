title = lt.Layer()

local container = lt.Layer()

title:Insert(code_bg_lyr)
title:Insert(import "titleFrame")

--Action Bars
clear_action_bars()

local
function show_modal(lbl, var, max_char, size)
    title:Remove(container)
    txt_box_lyr = make_text_box(lbl, var, max_char, size,
                    function(text)
                      title:Remove(txt_box_lyr)
                      title:Insert(container)
                    end)
    title:Insert(txt_box_lyr)
end

--about
local about_lyr = lt.Layer()
local about_pnl = lt.Layer()
local about_hdr = panel_header("ABOUT", -0.9, 0.9)
local about_body = panel_body(0.3, -0.4)
local about_lbls = {"FAQ", "SUBSCRIBE"}
about_pnl:Insert(about_hdr)
about_pnl:Insert(about_body)
about_body:Insert(make_action_bars(about_lbls):Translate(0, 0.1))

action_bars["FAQ"].action = function()
  main_scene:Remove(title)
  import "faq"
end

action_bars["SUBSCRIBE"].action = function()
  show_modal("EMAIL TO GET UPDATES FROM " .. config.codetypist_lbl, "_email", 86, 3.3)
end

about_lyr:Insert(about_pnl)

--l, t, r, b (rect order)
local prof_lyr = lt.Layer()
local profile_pnl  = lt.Layer()
local profile_hdr  = panel_header("PROFILE", -0.9, 0.9)
local profile_body = panel_body(0.3, -0.3)
profile_pnl:Insert(profile_hdr)
profile_pnl:Insert(profile_body)

local input_lbls = {"NAME"}
profile_body:Insert(make_action_bars(input_lbls):Translate(0, 0))
prof_lyr:Insert(profile_pnl)
for i,lbl in ipairs(input_lbls) do
  action_bars[lbl].action =  function()
    --25 max chars, 1.2 the width
    show_modal(lbl, "_username", 25, 1.2)
  end
end

--language panel
local lang_lyr = lt.Layer()
local ls_hdr  = panel_header("SELECT", -1, 1)
local ls_body = panel_body(0.3, -2.15)
lang_lyr:Insert(ls_hdr)
lang_lyr:Insert(ls_body)

local lang_labels = {"OBJECTIVEC", "JAVASCRIPT", "PYTHON", "SCALA", "RUBY",  "CPP", "GO", "C"}
ls_body:Insert(make_action_bars(lang_labels):Translate(0, 0.15))
--make actions for each of the label
for _,lbl in ipairs(lang_labels) do
  action_bars[lbl].action = function()

    --get name before procedin
    local _uname = lt.state["_username"]
    if _uname == nil or _uname == "" then
      show_modal("NAME", "_username", 25, 1.2)
    end

    action_bars[lbl]:Action(function(dt, node)
      if lt.state["_username"] ~= "" then
        config.cur_lang = lbl
        main_scene:Remove(title)
        import "typing"
      end
    end)

  end
end

--onweb panel
local onweb_lyr = lt.Layer()
local onweb_hdr  = panel_header("ON THE WEB", -0.9, 0.9)
local onweb_body = panel_body(0.3, -0.6)
onweb_lyr:Insert(onweb_hdr)
onweb_lyr:Insert(onweb_body)

local social_lbls = {"TWITTER", "FACEBOOK", config.codetypist_lbl}
onweb_body:Insert(make_action_bars(social_lbls):Translate(0, 0.15))
--actions
for _,lbl in ipairs(social_lbls) do
  action_bars[lbl].action = function()
    if lbl == "TWITTER" then
      open_url(config.codetypist_twitter)
    elseif lbl == "FACEBOOK" then
      open_url("http://fb.com")
    elseif lbl == config.codetypist_lbl then
      open_url(config.codetypist_web)
    end
  end
end

--action bar selections
action_bars[action_bar_idx].select = true

--panels
local panels = lt.Layer()
local t = config.margin.top - 0.2 - 0.4
panels:KeyDown(function(e)
  handle_quit(e)
  if e.key == "F" then
    lt.state.fullscreen = not lt.state.fullscreen
    lt.SetFullScreen(lt.state.fullscreen)
  end

  action_bar_changed(e.key)

  if e.key == "enter" then
    action_execute()
  end

end)

panels:Insert(lang_lyr:Translate(-0.0, t))
panels:Insert(about_lyr:Translate(-2.1, t))
panels:Insert(prof_lyr:Translate(-2.1, t - 1.1))
panels:Insert(onweb_lyr:Translate(2.1, t))

container:Insert(panels:Translate(0, -3):Tween{x=0, y=0, time=0.3, easing="accel"})
title:Insert(container)

title:PointerDown(function(event)
  main_scene:Remove(title)
  import "titleInstructions"
end)

main_scene:Insert(title)

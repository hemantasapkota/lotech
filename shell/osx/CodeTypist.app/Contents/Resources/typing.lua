-- Hierarchy
--  type_scene
--    -container
--      - left_pane
--              - code_txt
--              - curs_lyr
--              - editor_input
--              - lines lyr
--      - right_pane
--      - modal box
type_scene = lt.Layer()

--some clearings
reset_overlay_color()
clear_action_bars()
main_scene:Remove(code_bg_lyr)

local container = lt.Layer()

--get view boundaries
local l, r, t, b = lt.config.world_left, lt.config.world_right, lt.config.world_top, lt.config.world_bottom

--define some constants
local txt_scl, line_no_scl = 0.4, 0.4
local left_margin= l + 0.25
local top_margin = t - 0.2

local c = {
  x = 0,
  y = 0,
  index = 0,
  em = nil,
  retCount = 0,
  input = "",
  err = false,
  scrolling = false,
  del_typd = false,
  enter_typd = false,
  typing_owatta = false,
  err_cnt = 0,
  elapsed_secs = 0,
  ldr_elapsed = 0, --time before polling new high scores
  wpm,
  lines_txt = "",
  lines_cnt = 1,
  start_timing = false,
  esc_menu_showing = false,
  lang_pack_cur_idx = 0,
}

-- main_layer.child = make_keyboard(function(event)
-- end);

--left pane
local left_pane = lt.Layer()

--end functions
local ftext = lang_import_data()
--Count the number of lines, Make a string of line numbers
for i in ftext:gmatch("\n") do
    c.lines_txt = c.lines_txt .. c.lines_cnt .. "\n"
    c.lines_cnt = c.lines_cnt + 1
end

local scroll_limits = {25, 50, 75, 100, 125}
local scroll_index = 1

local code_txt = lt.Text(ftext, font, "left", "top")
                :Scale(txt_scl)
                :Translate(left_margin, top_margin)
                :Tint(unpack(config.sol_base01))
left_pane:Insert(code_txt)
container:Insert(left_pane)

--cursor
local curs_lyr = lt.Wrap()
left_pane:Insert(curs_lyr)
local hmove, vmove, spacemove = 0.0081249997019768,0.35250002145767,0.16249999403954

local
function em(c)
  if c == " " then
    return {width = spacemove, height = 0.3}
  end
  if c == "\n" then
    return {width = 0.1, height = 0.3}
  end
  if c == "\"" then
  end
  return font[c]
end

local
function update_cursor()
  --update cursor
  local index = #c.input
  c.em = em(ftext:sub(index, index)) or {width = spacemove, height = 0.3}
  --calculate x coord so far
  local i = 1
  c.x = 0
  c.retCount = 0
  while i <= #c.input do
    local char = c.input:sub(i, i)
    local t = em(char)

    --Rules:
    --If char is space, we don't add the hmove factor
    if char == " " then
      c.x = c.x + t.width
    else
      c.x = c.x + hmove + t.width
    end

    if char == "\n" then
      c.x = 0
      c.retCount = c.retCount + 1
    end

    i = i + 1
  end
  --calculate y coord so far
  c.y = c.em.height * 0.5 * txt_scl
  c.y = c.y + c.retCount * vmove * txt_scl
  if c.index == 1 then
    c.x = 0
  end

  --Update cursor values
  c.x = c.x * txt_scl

  curs_lyr.child = lt.Rect(0, -c.em.height/2, c.em.width/2, c.em.height/2)
                        :Tint(1, 1, 1, 0.5)
                        :Scale(txt_scl)
                        :Translate(left_margin + c.x, top_margin - c.y)
end
update_cursor()

--editor
local txt_fld = lt.Wrap()
local
function update_char()
    txt_fld.child = lt.Text(c.input, font, "left", "top")

    --typing controls.
    local correct = ftext:sub(#c.input, #c.input)
    local typed = c.input:sub(#c.input, #c.input)
    c.err = (not (typed == correct))
    --update error
    if c.err then
      if c.del_typed then
        return
      end
      c.err_cnt = c.err_cnt + 1
    end

    if #c.input == #ftext - 1 then
      c.typing_owatta = true
    end

    update_cursor()
end
update_char()

local editor_input = lt.Layer(txt_fld);
left_pane:Insert(editor_input:Scale(txt_scl):Translate(left_margin, top_margin))

left_pane:Action(function(node, dt)
  if c.scrolling then
    return false
  end

  if c.retCount == scroll_limits[scroll_index] then
    c.scrolling = true
    scroll_index = scroll_index + 1

    container:Remove(left_pane)
    left_pane = left_pane:Translate(0, 0)
      :Tween{x=0, y = 3.55, time=0.3, action = function()
      end}
    container:Insert(left_pane)
  end

end)

local editor_keyhandler = function(event)
  --reset scrolling
  for k,v in ipairs(scroll_limits) do
    if scroll_index == k then
      c.scrolling = false
    end
  end

  --if enter is pressed, then don't show error flash
  c.enter_typd = false
  if event.key == "enter" then
    c.enter_typd = true
    local i = #c.input + 1
    -- if ftext:sub(i, i) ~= "\n" then
    --   --if the next char is not "enter" don't go to next line
    --   return
    -- end
  end

  local chr = key_map[event.key] or " "

  --start timing
  c.start_timing = true

  c.del_typd = false
  if event.key == "del" then
    c.del_typd = true
    c.input = c.input:sub(1, -2)
  else
    c.input = c.input .. chr
  end

  update_char()

end
editor_input.key_down = editor_keyhandler

function show_esc_menu(menu_type)
  local start_lyr  = lt.Layer()
  start_lyr:Insert(lt.Rect(l, b, l + .75*(r-l), t):Tint(0, 0, 0, 0.4))
  local start_pnl  = lt.Layer()
  local start_hdr  = panel_header("WELL DONE", -1.1, 1.1)
  local start_body = panel_body(0.3, -0.7)
  start_pnl:Insert(start_hdr)
  start_pnl:Insert(start_body)

  local body_part = lt.Layer()
  local lbls = {"TWEET", "NEXT", "REPEAT"}
  body_part:Insert(make_action_bars(lbls))
  action_bars["TWEET"].select = true
  action_bars["TWEET"].action = function()
    local t_url = "https://twitter.com/intent/tweet?text=\""
    t_url = t_url .. "I scored " .. c.wpm .. " #WPM typing #" .. string.lower(config.lang_opts.sel_lang) ..
            " on @CodeTypist. #CodeTypist. "
    t_url = t_url .. config.codetypist_web .. " \""
    open_url(t_url)
    -- lt.OpenURL(t_url) -- for ios
  end

  action_bars["REPEAT"].action = function()
    lang_mark_repeat()
    main_scene:Remove(type_scene)
    import "typing"
  end

  action_bars["NEXT"].action = function()
    main_scene:Remove(type_scene)
    import "typing"
  end

  start_body:Insert(body_part:Translate(0, 0.1))

  local lx = l + .50*(r-l) - .6
  start_lyr:Insert(start_pnl:Translate(lx, 2):Tween{x=lx, y=0.5, time=0.3, easing="accel"})

  c.esc_menu_showing = true

  return start_lyr
end

editor_input:Action(function(dt, node)
  if c.err then
    c.err = false
    if not c.del_typd and not c.enter_typd then
      overlay:Tween{ red = config.pom[1],
                     blue = config.pom[2],
                     green = config.pom[3],
                     time = 0.2, action = function()
        reset_overlay_color()
      end}
    end
  end

  if c.typing_owatta then
      --submit score to leaderboard
      submit_score(
        {
          lang   = string.lower(config.lang_opts.sel_lang),
          file   = lang_sel_file(),
          player = string.lower(lt.state["_username"]),
          time   = c.elapsed_secs,
          error  = c.err_cnt,
          wpm    = c.wpm,
          accr   = c.accuracy
        },
        function()
          --if sucessfully submitted scores, update it
          update_scores_ui(leaderboard_body_part)
        end
      )
      lang_mark_completed()
      container:Insert(show_esc_menu())
      editor_input.key_down = nil
      c.typing_owatta = false
      c.start_timing = false
  end

end)

--line numbers
local lines_lyr = lt.Layer()
local max_bottom = #c.lines_txt * -0.15
if max_bottom > b then
  max_bottom = b
end
lines_lyr:Insert(lt.Rect(l, t, 0.25, max_bottom):Tint(unpack(config.sol_base02)))
lines_lyr:Insert(
    lt.Text(c.lines_txt, font, "left", "top")
      :Scale(line_no_scl)
      :Tint(unpack(config.sol_base1))
      :Translate(0.25/6, top_margin)
)
left_pane:Insert(lines_lyr:Translate(l, 0))

--right pane
local right_pane = lt.Layer()
local ui_txt_scl = 0.4

--right pane: at 75% of the total width
local r_start = l + .75 * (r-l)
local rx = r_start + 0.1
local ty = t

right_pane:Insert(lt.Rect(r_start, t, r, b):Tint(unpack(config.sol_base02)))

ty = t - 0.1
right_pane:Insert(
            lt.Text("CODE TYPIST", fontui, "center", "top")
               :Scale(ui_txt_scl)
               :Translate(r_start + (r-r_start)/2, ty)
)

ty = ty - 0.2
right_pane:Insert(
            lt.Text("PRESS ESC FOR MENU", fontui, "center", "top")
              :Tint(unpack(config.sol_base01))
              :Scale(ui_txt_scl * 0.8)
              :Translate(r_start + (r-r_start)/2, ty)
)

--show user name
ty = ty - 0.4
local usr_lyr = lt.Layer():Translate(r_start + (r-r_start)/2, ty)
usr_lyr:Insert(panel_header(lt.state["_username"], -0.89, 0.89, config.sol_base0))
right_pane:Insert(usr_lyr)

local
function make_dynamic_label(lbl, init_value, comp_color, action)
  local lyr = lt.Layer():Scale(ui_txt_scl)
  local lbl = lt.Text(lbl, fontui, "left", "top"):Translate(0, 0):Tint(unpack(config.white))
  local dyn = lt.Wrap(lt.Text("" .. init_value, fontui, "left", "top")):Translate(3, 0)
  local updater = function(v)
    if c.esc_menu_showing then
      dyn.child = lt.Text("" .. v, fontui, "left", "top"):Tint(unpack(comp_color))
    else
      dyn.child = lt.Text("" .. v, fontui, "left", "top")
    end
  end
  dyn:Action(function(dt, node)
    action(dt, updater)
  end)
  lyr:Insert(lbl)
  lyr:Insert(dyn)
  return lyr
end

-- Elapsed Time
local elapsed = 0
ty = ty - 0.3
local time_lyr = lt.Layer():Translate(rx, ty)
time_lyr:Insert(make_dynamic_label("Time(secs)", 0, config.base2,
function(dt, updater)
  if not c.start_timing then
    return
  end
  elapsed = elapsed + dt
  if elapsed >=1 and (not c.esc_menu_showing) then
    c.elapsed_secs = c.elapsed_secs + 1
    updater(c.elapsed_secs)
    elapsed = 0
  end
end))
right_pane:Insert(time_lyr)

-- Errors:
ty = ty - 0.2
local err_lyr = lt.Layer():Translate(rx, ty)
err_lyr:Insert(make_dynamic_label("Error", 0, config.alizarin,
function(dt, updater)
  updater(c.err_cnt)
end))
right_pane:Insert(err_lyr)

-- WPM:
ty = ty - 0.2
local wpm_lyr = lt.Layer():Translate(rx, ty)
wpm_lyr:Insert(make_dynamic_label("WPM", 0, config.emerland,
function(dt, updater)
  local total = #ftext
  local typed = #c.input
  c.wpm = math.ceil(((typed/5) - c.err_cnt) / (c.elapsed_secs / 60))
  -- c.wpm ~= c.wpm checks if it's a number
  if c.wpm ~= c.wpm then
    c.wpm = 0
  end

  updater(c.wpm)
end))
right_pane:Insert(wpm_lyr)

-- accuracy
ty = ty - 0.2
local accr_lyr = lt.Layer():Translate(rx, ty)
accr_lyr:Insert(make_dynamic_label("Accuracy", 0, config.turquoise,
function(dt, updater)
  local cin = #c.input + 1 --add one more char to ensure we get 100% accuracy count
  local a = (cin - c.err_cnt) / #ftext
  c.accuracy = math.ceil(a * 100)
  updater(c.accuracy .. "%")
end))
right_pane:Insert(accr_lyr)

--leaderboards
ty = ty - 0.4
local ldr_lyr = lt.Layer():Translate(r_start + (r-r_start)/2, ty)
local ldr_headr = panel_header("LEADERBOARD", -0.89, 0.89, config.sol_base0)
local ldr_body = panel_body(0.3, -1.6)

--leaderboard_body_part is a global
leaderboard_body_part = lt.Wrap()
update_scores_ui(leaderboard_body_part)

ldr_body:Insert(leaderboard_body_part)
ldr_lyr:Insert(ldr_headr)
ldr_lyr:Insert(ldr_body)

right_pane:Insert(ldr_lyr)
container:Insert(right_pane)

container:KeyDown(function(event)
  if event.key == "unknown" then
    return
  end

  if event.key == "down" or event.key == "left" or
    event.key == "up" or event.key == "right" then
    if not editor_input.key_down then
      action_bar_changed(event.key)
    end
    return
  end

  if not editor_input.key_down then
    if event.key == "enter" then
      action_execute()
    end
  end

  if event.key == "esc" then
    main_scene:Remove(type_scene)
    reset_overlay_color()
    import "title"
    return
  end

  if editor_input.key_down then
    editor_input.key_down(event)
  end

end)

container:KeyUp(function(event)
end)

type_scene:Insert(container)
main_scene:Insert(type_scene)

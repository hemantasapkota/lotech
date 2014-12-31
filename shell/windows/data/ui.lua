function open_url(url)
  log(lt.os)
  if lt.os == "osx" then
    os.execute("open " .. url)
  elseif config.os() == "windows" then
    os.execute("start " .. url)
  end
end

function _txt(val)
  return lt.Text(val, fontui, "center", "center")
end

function _txt_base1(val)
  return lt.Text(val, fontui, "center", "center"):Tint(unpack(config.sol_base1))
end

function _txt_base01(val)
  return lt.Text(val, fontui, "center", "center"):Tint(unpack(config.sol_base01))
end

function _txt_base2(val)
  return lt.Text(val, fontui, "center", "center"):Tint(unpack(config.sol_base2))
end

function _txt_success(val)
  return lt.Text(val, fontui, "center", "center"):Tint(unpack(config.green))
end

function make_text_bar(str, y)
  local lyr = lt.Layer()
  local len = string.len(str)

  --calcultion for underline
  local index = 1
  local usize = 0
  while index <= len do
    local char = str:sub(index, index)
    local w = 0
    if char == " " then
      w = 0.29999998211861 -- fot fontui width for space
    else
      w = fontui[char].width
    end
    usize = usize + w * config.pnl_title_scl
    index = index + 1
  end
  local underline = lt.Rect(-usize/2, 0, usize/2, 0.04)
                    :Tint(unpack(config.sunflower))
                    :Translate(0, -y - 0.14)

  local lbl = lt.Layer():Scale(config.pnl_title_scl):Translate(0, -y)
  lbl:Insert(_txt_base2(str))
  lyr:Insert(lbl)

  lyr:PointerDown(function()
  end)

  lyr:Action(function(dt)
    if lyr.success then
      lbl:Insert(_txt_success(str))
    end

    if lyr.select then
      lyr:Insert(underline)
    else
      lyr:Remove(underline)
    end
  end)
  return lyr
end



_pnl_cch = {}
function panel_header(title, l, r, color)
  local lyr = lt.Layer()

  if color == nil then
    color = config.sol_base02
  end

  lyr:Insert(lt.Rect(l, 0.15, r, -0.15):Tint(unpack(color)))
  lyr:Insert(_txt_base2(title):Scale(config.pnl_title_scl))
  --save temps
  _pnl_cch.l = l
  _pnl_cch.r = r
  return lyr
end

function panel_body(t, b)
  local pb = lt.Layer()
  pb:Insert(lt.Rect(_pnl_cch.l, t, _pnl_cch.r, b):Tint(unpack(config.sol_base00)))
  return pb:Translate(0, -0.45)
end

action_bars = {}
action_bar_idx = 1
function make_action_bars(labels)
  local start_y, spacing_y, bar_lyr = 0, 0.3, lt.Layer()
  for _,v in pairs(labels) do
    local b = make_text_bar(v, start_y, pnl_title_scl)
    bar_lyr:Insert(b)
    table.insert(action_bars, b)
    action_bars[v] = b
    start_y = start_y + spacing_y
  end
  return bar_lyr
end

function action_execute()
  action_bars[action_bar_idx].action()
end

function action_bar_changed(key)
  if key ~= "up" and key ~= "down" then
    return
  end

  action_bars[action_bar_idx].select = false
  -- action_bars[action_bar_idx].success = true

  if key == "up" then
    action_bar_idx = action_bar_idx - 1
  elseif key == "down" then
    action_bar_idx = action_bar_idx + 1
  end

  if action_bar_idx > #action_bars then
    action_bar_idx = 1
  end

  if action_bar_idx < 1 then
    action_bar_idx = #action_bars
  end

  action_bars[action_bar_idx].select = true
  samples.uibleep:Play(1, 1)
end

function clear_action_bars()
  action_bar_idx = 1
  for k in pairs (action_bars) do
    action_bars[k] = nil
  end
end

function make_text_box(lbl, var, max_chars, dim, on_enter)
  local txt_box = lt.Layer()
  local l, r, t, b = lt.config.world_left, lt.config.world_right, lt.config.world_top, lt.config.world_bottom

  --transparent dark lightbox
  local bg_rect = lt.Rect(l, b, r, t):Tint(unpack(config.black))
  bg_rect.alpha = 0.6
  txt_box:Insert(bg_rect)

  --panel scaffold
  local input_pnl = lt.Layer()
  local hdr = panel_header("ENTER " .. lbl, -dim, dim)
  local body = panel_body(0.3, -0.3)
  input_pnl:Insert(hdr)
  input_pnl:Insert(body)
  txt_box:Insert(input_pnl:Translate(0, t):Tween{x=0, y=0.08, time=0.3, easing="zoomin"})

  local hmove, spacemove = 0.0081249997019768,0.16249999403954
  local make_body_part = function(txt)
    local _t = lt.Wrap()
    local _l = lt.Layer()
    local tx = 0
    for i = 1, #txt do
      local c = txt:sub(i, i)
      local w = 0
      if c == " " then
        w = spacemove
      else
        w = fontui[c].width
      end
      tx = tx + hmove * 2 + w * config.pnl_title_scl
    end
    _l:Insert(
      _txt_base2(txt)
        :Tint(unpack(config.sol_base02))
        :Scale(config.pnl_title_scl)
      )
    _l:Insert(
            lt.Rect(-0.03, 0.08, 0.03, -0.08)
              :Tint(unpack(config.sol_base1))
              :Translate(tx/2, 0)
              :Action(function(dt, node)
                if node.alpha > 0.5 then
                  node.alpha = node.alpha - 1.1 * dt
                else
                  node.alpha = 1
                end
              end)
    )
    _t.child = _l
    return _t
  end

  local txt_str = ""
  if lt.state[var] then
    txt_str = lt.state[var]
  end

  local _t = make_body_part(txt_str)
  body:Insert(_t)

  txt_box:KeyDown(function(event)
    local chr = event.key

    if chr == "enter" then
      lt.state[var] = string.upper(txt_str)
      on_enter(txt_str)
      return
    end

    if chr == "esc" then
      on_enter("")
      return
    end

    if ltd_keymap[chr] == nil then
      return
    end

    if chr == "del" then
      txt_str = txt_str:sub(0, #txt_str-1)
    else
      if #txt_str == max_chars then
        return
      end
      txt_str = txt_str .. ltd_keymap[chr]
    end

    _t.child = lt.Layer()
    _t.child = make_body_part(txt_str)
  end)

  return txt_box
end


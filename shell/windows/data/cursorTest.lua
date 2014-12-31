import "keymap"

local cursorTest = lt.Layer()

local blink = true
local cursor = lt.Rect(-0.02, -0.1, 0.01, 0.05):Tint(1, 1, 1, 1)
    :Action(function(dt, c)
        if blink then
            c.alpha = 1
        else
            c.alpha = 0
        end
        blink = not blink
        return 0.3
    end)
    :Translate(0, 0)

cursorTest:Insert(cursor:Scale(0.5))

--
lines = {current = "", x = 0, y = 0}
current_char = ""
local
function make_char(ch)
  local text_field = lt.Wrap()
  text_field.child = lt.Text(ch, font, "left", "left")
  lines.x = lines.x + 0.12
  -- cursorTest:Insert(text_field:Scale(0.6):Translate(lines.x, lines.y))
  -- cursor.x = #lines.current * 0.16
end


cursorTest:KeyDown(function(e)
  handle_quit(e)

  if e.key == "unknown" then
    return
  end

  if e.key == "del" then
    input = input:sub(1, -2)
  end

  local chr = key_map[e.key]
  lines.current = lines.current .. chr
  -- current_char = current_line .. chr
  make_char(chr)

end)

main_scene:Insert(cursorTest)

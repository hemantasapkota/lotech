math.randomseed(os.time())

import "keyboard"
import "keymap"
import "limited_keymap"
import "ui"

--lt.FixGlobals()
-----------------------------
world = box2d.World(0, -25)
world.auto_clear_forces = true
world.scale = 1

images = lt.LoadImages({
  "code_bg"
})

samples = lt.LoadSamples({
  "uibleep"
  })

fontImages = lt.LoadImages(
  {
    {
      font = "font",
      glyphs = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890`'~!@#$%^&*()-=_+{}[]:;<>,.?|\\/"
    },
    {
      font = "font_ui",
      glyphs = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890`'~!@#$%^&*()-=_+{}[]:;<>,.?|\\/"
    }
  },
  "linear",
  "linear")

font = fontImages.font
fontui = fontImages.font_ui

main_layer = lt.root
main_layer.child = lt.Layer()

overlay = lt.Wrap(lt.Rect(lt.left, lt.top, lt.right, lt.bottom):Tint(unpack(config.sol_base03)))
function reset_overlay_color()
  overlay.child = lt.Rect(lt.left, lt.top, lt.right, lt.bottom):Tint(unpack(config.sol_base03))
end

main_scene = main_layer.child

main_scene:Action(function(dt)
end)

-- main_scene:KeyDown(function(event)
--   handle_quit(event)
-- end)

function handle_quit(event)
  if event.key == "esc" then
    lt.Quit()
  end
end

main_scene:Insert(overlay)

--code bg
code_bg_lyr = lt.Layer():Translate(0, 0)
code_bg_lyr:Insert(images.code_bg:Translate(0, -3))
code_bg_lyr:Action(function(dt, node)
  node.y = node.y + 0.1 * dt
  if node.y > lt.config.world_top * 2 then
    node.y = -1
  end
end)

print(lt.os)

import "title"

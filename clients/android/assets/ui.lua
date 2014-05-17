local
function makeTweenButton(font, str, tx, ty, onClick)
  local lyr = lt.Layer()
  local txt = lt.Text(str, font, "center", "center")
  local rect = lt.Rect(txt.left, txt.top, txt.right, txt.bottom):Tint(1, 1, 1, 0)

  lyr:Insert(rect)
  lyr:Insert(txt:Tint(1,1,1))

  rect:PointerDown(onClick, rect.x1, rect.y2, rect.x2, rect.y1)

  return lyr:Translate(0, 0, 0):Tween{x=tx, y=ty, time=0.4}
end

function makeGameUI()
  local uiLayer = lt.Layer()

  local optionsBtn = makeTweenButton(font, "Options", 0, 4, function(node)
  end)

  local playBtn = makeTweenButton(font, "Play", 0, 2, function(node)
    import "play"
  end)

  uiLayer:Insert(optionsBtn:Scale(0.6))
  uiLayer:Insert(playBtn:Scale(0.6))

  return uiLayer
end

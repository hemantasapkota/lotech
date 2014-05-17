math.randomseed(os.time())

import "commons"
import "ui"
import "audio"
import "level"

--lt.FixGlobals()
-----------------------------
player = {
  defaultState = {running = true},
  state = {running = true},

  config = {
    run = {
      fps = 60,
      size = {w=0.25, h=0.5}
    },

    jump = {
      fps = 1,
      time = 0.26
    },

    roll = {
      fps = 60,
      size = {w=0.25, h=0.25},
      time = 0.45
    }
  }

}

layers, gameStarted = {}, false
world = box2d.World(0, -25)
world.auto_clear_forces = true

main_layer = lt.root

-- world.debug = true
world.scale = 1

local
function makeAndroidControls()
  local t,b,l,r = lt.config.world_top, lt.config.world_bottom, lt.config.world_left, lt.config.world_right
  local controls = lt.Layer()

  local w, h = 0 - l, 0 - t

  local cl = lt.Rect(l, t, 0, h):Tint(0, 0, 0, 0)
  local cr = lt.Rect(0, t, w, h):Tint(0, 0, 0, 0)

  if world.debug then
    cl = cl:Tint(1, 1, 1, 0.3)
    cr = cr:Tint(1, 0, 1, 0.3)
  end

  cl:PointerDown(function()
    player.state = {ducking = true}
  end,l,h,0,t)

  cr:PointerDown(function()
    player.state = {jumping = true}
  end,0,h,w,t)

  controls:Insert(cl)
  controls:Insert(cr)

  return controls
end

function start()
  --clear
  if layers["terrain"] then
    for _,body in ipairs(layers["terrain"].bodies) do
      body:Destroy()
    end
  end

  if main_scene then
    main_scene:Remove(layers["bg"])
    main_scene:Remove(layers["ground"])
    main_scene:Remove(layers["terrain"])
    main_scene:Remove(layers["controls"])
    main_scene:Remove(layers["ui"])
    unmakeSound("title")
  end
  --End clear

  main_layer.child = lt.Layer()
  main_scene = main_layer.child

  --Main layer
  local debugLayer = lt.Layer()

  layers["bg"] = makeBG()
  layers["ground"] = makeGround()
  layers["terrain"] = makeTerrain()
  layers["controls"] = makeAndroidControls()
  layers["ui"] = makeGameUI()

  main_scene:Insert(layers["bg"])
  main_scene:Insert(layers["ground"])
  main_scene:Insert(layers["terrain"])
  main_scene:Insert(layers["controls"])
  main_scene:Insert(layers["ui"])
  main_scene:Insert(makeSound("title"))

  main_scene:Action(function(dt)
    world:Step(dt)
    lt.AdvanceGlobalSprites(dt)

    if world.debug then
      main_scene:Remove(debugLayer)
      debugLayer = lt.Text("Bodies Count: " .. world.body_count, font, "center", "center"):Scale(0.3)
      main_scene:Insert(debugLayer)
    end

  end)

  main_scene:KeyDown(function(event)
    if event.key == "enter" then

      if not gameStarted then
        import "play"
      end

    elseif event.key == "up" then

      if player.rollTimer == 0 then
        main_scene:Insert(makeSound("jump"))
        player.state = {jumping = true}
      end

    elseif event.key == "down" then
      player.state = {ducking = true}
    elseif event.key == "esc" then
      lt.Quit()
    end

  end)

  main_scene:KeyUp(function(event)
    if event.key == "up" then

      unmakeSound("jump")

      if player.jumpTimer == 0 then
        player.state = player.defaultState
      end

    end
  end)
end

start()

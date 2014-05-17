local
blockPatterns = {}

blockPatterns["p1"] = {
  top = {0,0,0,1,0,0,0,0},
  dwn = {0,1,0,0,0,0,1,0}
}

blockPatterns["p2"] = {
  top = {0,0,0,0,0,0},
  dwn = {0,1,0,0,0,1}
}

blockPatterns["p3"] = {
  top = {0,0,0,0,0,0},
  dwn = {0,1,0,1,0,0}
}

function makeBG()
  local l,t,r,b = lt.config.world_left, lt.config.world_top, lt.config.world_right, lt.config.world_bottom

  local bgLayer = lt.Layer()

  local bg = lt.Layer():BlendMode("add"):Tint(0.5, 0.5, 0.5, 1)
  bg.child = lt.Layer()
  bg.child:Insert(images.bg1:Scale(0.3))
  bgLayer:Insert(bg)

  local bg2 = lt.Layer():BlendMode("subtract"):Tint(1, 1, 1, 1)
  bg2.child = lt.Layer()
  bg2.child:Insert(images.bg2:Scale(0.28))
  bgLayer:Insert(bg2)

  local bg3 = lt.Layer():BlendMode("add"):Tint(1, 1, 1, 1)
  bg3.child = lt.Layer()
  bg3.child:Insert(images.bg2:Scale(0.4))
  bgLayer:Insert(bg3)

  local tx = 0
  bgLayer:Action(function(dt, node)
    bgLayer:Remove(bg3)
    bg3 = bg3:Translate(tx, 0)
    bgLayer:Insert(bg3)
    tx = tx - 0.001 * dt
    if tx < lt.config.world_left then
      tx = 0
    end
  end)

  return bgLayer
end

function makeGround()
  local groundLayer = lt.Layer()
  local g = { x = -2.5, y = -2}

  local w, h = 10, 0.18
  local ground_body = world:Body({type="static", x=g.x, y=g.y})
  local ground_fix = makeBox(ground_body, w, h)

  groundLayer:Insert(ground_body)
  groundLayer:Insert(images.ground:Scale(0.4, 0.2):Translate(g.x, g.y))

  return groundLayer
end

function makeTerrain()
  local terrainLayer = lt.Layer()
  terrainLayer.bodies = {}

  local
  function makePattern(startPos, pat)
    for k,pattern in ipairs(pat) do
      if pattern == 1 then

        local body = makeBlock(startPos.x + k, startPos.y  + 0.23*2)
        body.vx = -6
        body:Action(function(dt, b)
          if b.x < lt.config.world_left then
            b:Destroy()
          end
        end)

        terrainLayer:Insert(body)
        table.insert(terrainLayer.bodies, body)
      end
    end
    return #pat
  end

  local startPos = {x = 10, y = -2}
  local startPos2 = {x = 10, y = -1}

  terrainLayer:Action(function(dt)
    if world.body_count > 10 then
      return
    end

    local p = 'p' .. math.random(1,2)

    local nextPos1 = makePattern(startPos, blockPatterns[p].dwn)
    local nextPos2 = makePattern(startPos2, blockPatterns[p].top)

    startPos.x = startPos.x + nextPos1 + 2
    startPos2.x = startPos2.x + nextPos2 + 2
  end)

  return terrainLayer
end

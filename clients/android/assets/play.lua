local
function makePlayer()
  local playerLayer = lt.Layer()
  local images = {}
  lt.AddSpriteFiles(images, "run", 15)
  lt.AddSpriteFiles(images, "roll", 28)

  local frames = lt.LoadImages(images, "linear", "linear")
  local runSprite = lt.Sprite(lt.MatchFields(frames, "run_%d"), player.config.run.fps):Scale(0.6)
  local jumpSprite = lt.Sprite(lt.MatchFields(frames, "run_0001"), 1):Scale(0.6)
  local rollSprite = lt.Sprite(lt.MatchFields(frames, "roll_%d"), player.config.roll.fps):Scale(0.6)

  player.body = world:Body({type="dynamic", x=-0.6, y=0.9, fixed_rotation="false"})
  local player_fixture = makeBox(player.body, player.config.run.size.w, player.config.run.size.h)

  local r = {restart = false, restartTimer = 0}
  local playerNode = {}
  player.rollTimer, player.jumpTimer = 0, 0

  player.body:Action(function(dt, node)

    if r.restart then
      r = {restart = false, restartTimer = 0}
      gameStarted = false
      unmakeSound("hit")
      start()
      return
    end

    --Destroy body if it goes outside viewport
    if player.body.y < lt.config.world_bottom then
      player_fixture:Destroy()
      player.body:Destroy()
      layers["player"]:Remove(player.body)
      main_scene:Remove(layers["player"])
    end

    --if the player contacts a block, destroy it
    local touching = player_fixture:Touching()
    for k, v in ipairs(touching) do
      if v.block == true then

        main_scene:Insert(makeSound("hit"))
        player_fixture:Destroy()
        player.body:AngularImpulse(-30)
        player.body:Impulse(-2, 4)

        r.restart = true
        break;
      end
    end

    if player.state.running then
      playerNode = runSprite

      player_fixture:Destroy()
      player_fixture = makeBox(player.body, player.config.run.size.w, player.config.run.size.h)
    end

    if player.state.jumping then
      if player.body.y then
        player.body.y =  player.body.y + 0.2
      end

      playerNode = jumpSprite

      player.jumpTimer = player.jumpTimer + dt
      if player.jumpTimer > player.config.jump.time then
        jumpSprite.child:Reset()
        player.state = { running = true}
        player.jumpTimer = 0
      end

    end

    if player.state.ducking then
      playerNode = rollSprite:Translate(0, 0.4)

      player_fixture:Destroy()
      player_fixture = makeBox(player.body, 0.3, 0.3)
      player.body.y = player.body.y -  0.3

      --Limit rolling
      player.rollTimer = player.rollTimer + dt
      if player.rollTimer > player.config.roll.time then
        rollSprite.child:Reset()
        player.state = {running  = true}
        player.rollTimer = 0
      end
    end

    node.child = playerNode
  end)

  playerLayer:Insert(player.body)
  return playerLayer
end

gameStarted = true

main_scene:Remove(layers["ui"])
main_scene:Remove(layers["terrain"])

for _,body in ipairs(layers["terrain"].bodies) do
  body:Destroy()
end

if player.body then
  player.body:Destroy()
end

unmakeSound("title")

layers["player"] = makePlayer()
layers["terrain"] = makeTerrain()

main_scene:Insert(layers["player"])
main_scene:Insert(layers["terrain"])

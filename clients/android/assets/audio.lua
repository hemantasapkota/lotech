local tracks = {}

local samples = lt.LoadSamples({
  "title",
  "hit",
  "jump"
})

function makeSound(title)
  local sound = lt.Track()
  sound.loop = false
  sound:Queue(samples[title])
  sound:Play()
  tracks[title] = sound
  return sound
end

function unmakeSound(title)
  if tracks[title] then
    main_scene:Remove(tracks[title])
  end
end

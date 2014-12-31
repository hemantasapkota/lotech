local lyr = lt.Layer()

local
function _txt_left(txt)
  return lt.Text(txt, fontui, "left", "top")
end

local questions, answers = {}, {}
local
function _q(opts)
  table.insert(questions, opts.q)

  --calculate the size
  local ydim = 0.6 + #questions * - 0.5
  local ncount = 0
  for v in pairs(answers) do
   local _,cnt = string.gsub(answers[v], "\n", "")
   ncount = ncount + cnt
  end
  ydim = ydim - ncount *  0.13

  local lyr = lt.Layer():Scale(config.pnl_title_scl):Translate(0, ydim)
  lyr:Insert(_txt_left(#questions .. "."):Translate(0, 0))
  lyr:Insert(_txt_left(opts.q):Tint(unpack(config.sol_base2)):Translate(0.4, 0))
  lyr:Insert(_txt_left(opts.a):Tint(unpack(config.sol_base1)):Translate(0.4, -0.5))

  table.insert(answers, opts.a)

  return lyr
end

local l = lt.config.world_left + 0.2
local qa_lyr = lt.Layer():Translate(l, 0)

qa_lyr:Action(function(dt, node)
  node.y = node.y + dt * 0.1
  if node.y > 3 then
    node:Tween{x= l, y = 0, time = 0.2}
  end
end)

qa_lyr:Insert(_q{
  q = "What is Code Typist ?",
  a = "An app/game for practicing typing real codes."
})

qa_lyr:Insert(_q{
  q = "Is it a typing tutor ?",
  a = "NO"
})

qa_lyr:Insert(_q{
  q = "Will this app help me get better at typing codes ?",
  a = "Yes. You'll probably be competing with the fastest hackers." ..
      "\nTo come up to their level, you'll have to up your game." ..
      "\nThis might include:" ..
      "\n 1. Learning touch typing" ..
      "\n 2. Getting a mechanical keyboard" ..
      "\n 3. Learning VIM or Emacs ( Optional )"
})

qa_lyr:Insert(_q{
  q = "Where did the inspiration come from ?",
  a = "From the wonderful apps like:" ..
      "\n Mavis Beacon Teaches Typing" ..
      "\n typing.io" ..
      "\n typeracer.com"
})

qa_lyr:Insert(_q{
  q = "Who's the developer ?",
  a = "Brought to you with love by Hemanta Sapkota from Sydney." ..
      "\nFollow me on:" ..
      "\nTwitter: @laex_pearl" ..
      "\nGitHub: http://github.com/hemantasapkota"
})

qa_lyr:Insert(_q{
  q = "What's your privacy policy ?",
  a = ""
})

lyr:Insert(qa_lyr)
lyr:Insert(import "titleFrame")

lyr:KeyDown(function(event)
  if event.key == "esc" then
    main_scene:Remove(lyr)
    import "title"
  end
end)

main_scene:Insert(lyr)

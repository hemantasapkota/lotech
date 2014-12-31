lt.config.short_name = "Code Typist"
lt.SetAppShortName(lt.config.short_name)
lt.RestoreState()

-- Display setup
aspect_ratio = 480/320
if lt.form_factor == "desktop" then
    aspect_ratio = 1280/720
end
viewport_height = 4
viewport_width = viewport_height * aspect_ratio
viewport_left = -viewport_width / 2
viewport_right = -viewport_left
viewport_bottom = -viewport_height / 2
viewport_top = -viewport_bottom

lt.config.world_left = viewport_left
lt.config.world_right = viewport_right
lt.config.world_bottom = viewport_bottom
lt.config.world_top = viewport_top

lt.config.design_width = 640 * aspect_ratio
lt.config.design_height = 640
lt.config.orientation = "landscape"
if lt.form_factor == "desktop" then
    if lt.state.fullscreen == nil then
        lt.state.fullscreen = false
    end
else
    lt.state.fullscreen = false
end
lt.config.fullscreen = lt.state.fullscreen
if lt.form_factor == "desktop" then
    lt.config.letterbox = not lt.config.fullscreen
else
    lt.config.letterbox = false
end
lt.config.show_mouse_cursor = not lt.config.fullscreen

lt.config.start_script = "main"

config = {}

config.bg_w = 320 * aspect_ratio
config.bg_h = 320
if lt.form_factor == "desktop" then
    config.bg_w = 640 * aspect_ratio
    config.bg_h = 640
end

config = {}
setfenv(1, config)

--margin left right top bottom
margin = {left = -2.5, right = 2.5, top = 1.8, bottom = -1.8}

--text scale values
head_scl, subhead_scl, pnl_title_scl = 0.6, 0.5, 0.4

--server url
leaderboard_url = "http://localhost:3000"
submit_score_url = leaderboard_url .. "/score/"
high_score_url = leaderboard_url .."/highscore/"

--
codetypist_lbl     = "CODETYPIST.COM"
codetypist_web     = "http://codetypist.com"
codetypist_fb      = "https://www.facebook.com/pages/Code-Typist/546849492119108"
codetypist_twitter = "http://twitter.com/codetypist"

--FlatUI colors
white = {1, 1, 1}
black = {0, 0, 0}
green = {0, 1, 0}

turquoise    = {26/255,  188/255, 156/255}
greensea     = {22/255,  160/255, 133/255}
emerland     = {46/255,  204/255, 113/255}
nephritis    = {39/255,  174/255, 96/255}
peterriver   = {52/255,  152/255, 219/255}
belizehole   = {41/255,  128/255, 185/255}
amethyst     = {155/255, 89/255,  182/255}
wisteria     = {142/255, 68/255,  173/255}
wetasphalt   = {52/255,  73/255,  94/255}
midnightblue = {44/255,  62/255,  80/255}
sunflower    = {241/255, 196/255, 15/255}
orange       = {243/255, 156/255, 18/255}
carrot       = {230/255, 126/255, 34/255}
pumpkin      = {211/255, 84/255,  0/255}
alizarin     = {231/255, 76/255,  60/255}
pom          = {192/255, 57/255,  43/255}
clouds       = {236/255, 240/255, 241/255}
silver       = {189/255, 195/255, 199/255}
concrete     = {149/255, 165/255, 166/255}
asbestos     = {127/255, 140/255, 141/255}

--Solarized
sol_base03  = {000/255, 043/255, 054/255}
sol_base02  = {007/255, 054/255, 066/255}
sol_base01  = {088/255, 110/255, 117/255}
sol_base00  = {101/255, 123/255, 131/255}
sol_base0   = {131/255, 148/255, 150/255}
sol_base1   = {147/255, 161/255, 161/255}
sol_base2   = {238/255, 232/255, 213/255}
sol_base3   = {253/255, 246/255, 227/255}
sol_yellow  = {181/255, 137/255, 000/255}
sol_orange  = {203/255, 075/255, 022/255}
sol_red     = {220/255, 050/255, 047/255}
sol_magenta = {211/255, 054/255, 130/255}
sol_violet  = {108/255, 113/255, 196/255}
sol_blue    = {038/255, 139/255, 210/255}
sol_cyan    = {042/255, 161/255, 152/255}
sol_green   = {133/255, 153/255, 000/255}

--Basic Lang Data Pack
lang_opts = {
  sel_lang = "",
  sub_idx = 1,
  lang_labels = { "OBJECTIVEC", "JAVASCRIPT", "PYTHON", "SCALA", "RUBY", "CPP", "GO", "C" }
}

data_packs = {}
data_packs["OBJECTIVEC"] = {
  {done = false, dir = "objectivec", file = "hello.m"},
  {done = false, dir = "objectivec", file = "popbouncy.mm"},
  {done = false, dir = "objectivec", file = "popanimatoritem.mm"},
  {done = false, dir = "objectivec", file = "reset.mm"},
  {done = false, dir = "objectivec", file = "layoutsubviews.mm"},
  {done = false, dir = "objectivec", file = "txtfieldchange.mm"},
  {done = false, dir = "objectivec", file = "close.m"},
  {done = false, dir = "objectivec", file = "mbprogresshud.mm"},
  {done = false, dir = "objectivec", file = "drawrect.mm"},
  {done = false, dir = "objectivec", file = "getobjects.mm"},
  {done = false, dir = "objectivec", file = "islegalutf8.mm"},
  {done = false, dir = "objectivec", file = "ghtestonmainthread.m"}
}

data_packs["JAVASCRIPT"] = {
  {done = false, dir = "javascript", file = "hello.js"},
  {done = false, dir = "javascript", file = "nodeserver.js"},
  {done = false, dir = "javascript", file = "gruntfile.js"},
  {done = false, dir = "javascript", file = "ngrepeat.js"},
  {done = false, dir = "javascript", file = "express.js"},
  {done = false, dir = "javascript", file = "color.js"},
  {done = false, dir = "javascript", file = "reactcontext.js"},
  {done = false, dir = "javascript", file = "reactmain.js"},
  {done = false, dir = "javascript", file = "eventemitter.js"},
  {done = false, dir = "javascript", file = "enginestep.js"},
  {done = false, dir = "javascript", file = "functionmixin.js"},
  {done = false, dir = "javascript", file = "userhelper.js"},
}

data_packs["PYTHON"] = {
  {done = false, dir = "python", file = "hello.py"},
  {done = false, dir = "python", file = "processpyx.py"},
  {done = false, dir = "python", file = "commitstats.py"},
  {done = false, dir = "python", file = "command.py"},
  {done = false, dir = "python", file = "adapter.py"},
  {done = false, dir = "python", file = "graphsearch.py"},
  {done = false, dir = "python", file = "quads.py"},
  {done = false, dir = "python", file = "nude.py"},
  {done = false, dir = "python", file = "decode.py"},
  {done = false, dir = "python", file = "api.py"},
  {done = false, dir = "python", file = "cornice.py"},
  {done = false, dir = "python", file = "feedly.py"},
}

data_packs["SCALA"] = {
  {done = false, dir = "scala", file = "position.scala"},
  {done = false, dir = "scala", file = "hello.scala"},
  {done = false, dir = "scala", file = "supportmethods.scala"},
  {done = false, dir = "scala", file = "execute.scala"},
  {done = false, dir = "scala", file = "bitset.scala"},
  {done = false, dir = "scala", file = "setlike.scala"},
  {done = false, dir = "scala", file = "anyref.scala"},
  {done = false, dir = "scala", file = "actorexecutor.scala"},
  {done = false, dir = "scala", file = "javainteraction.scala"},
  {done = false, dir = "scala", file = "beaninfo.scala"},
  {done = false, dir = "scala", file = "double.scala"},
  {done = false, dir = "scala", file = "proxy.scala"},
  {done = false, dir = "scala", file = "position.scala"},
}

data_packs["RUBY"] = {
  {done = false, dir = "ruby", file = "hello.rb"},
  {done = false, dir = "ruby", file = "less.rb"},
  {done = false, dir = "ruby", file = "emoji.rb"},
  {done = false, dir = "ruby", file = "authlogic.rb"},
  {done = false, dir = "ruby", file = "processrunner.rb"},
  {done = false, dir = "ruby", file = "shell.rb"},
  {done = false, dir = "ruby", file = "checkregexdos.rb"},
  {done = false, dir = "ruby", file = "gauntletflay.rb"},
  {done = false, dir = "ruby", file = "extensionhelper.rb"},
  {done = false, dir = "ruby", file = "dynamic.rb"},
  {done = false, dir = "ruby", file = "install.rb"},
  {done = false, dir = "ruby", file = "carmen.rb"},
}

data_packs["CPP"] = {
  {done = false, dir = "cpp", file = "hello.cpp"},
  {done = false, dir = "cpp", file = "setuppersp.cpp"},
  {done = false, dir = "cpp", file = "oflight.cpp"},
  {done = false, dir = "cpp", file = "singleton.cpp"},
  {done = false, dir = "cpp", file = "daevisualscene.cpp"},
  {done = false, dir = "cpp", file = "block.cpp"},
  {done = false, dir = "cpp", file = "sortedvector.cpp"},
  {done = false, dir = "cpp", file = "distancemachine.cpp"},
  {done = false, dir = "cpp", file = "distmachineapply.cpp"},
  {done = false, dir = "cpp", file = "sha1.cpp.lua"},
  {done = false, dir = "cpp", file = "b2rope.cpp"},
  {done = false, dir = "cpp", file = "gbcollector.cpp"},
}

data_packs["GO"] = {
  {done = false, dir = "go", file = "hello.go"},
  {done = false, dir = "go", file = "decode.go"},
  {done = false, dir = "go", file = "compute.go"},
  {done = false, dir = "go", file = "leveldb.go"},
  {done = false, dir = "go", file = "opendb.go"},
  {done = false, dir = "go", file = "logentrypb.go"},
  {done = false, dir = "go", file = "email.go"},
  {done = false, dir = "go", file = "newemail.go"},
  {done = false, dir = "go", file = "lua.go"},
  {done = false, dir = "go", file = "astar.go"},
  {done = false, dir = "go", file = "priorityq.go"},
  {done = false, dir = "go", file = "dialog.go"},
}

data_packs["C"] = {
  {done = false, dir = "c", file = "hello.c"},
  {done = false, dir = "c", file = "vectorsumnorm.c"},
  {done = false, dir = "c", file = "tmat.c"},
  {done = false, dir = "c", file = "pslattice.c"},
  {done = false, dir = "c", file = "psreinit.c"},
  {done = false, dir = "c", file = "arc4random.c"},
  {done = false, dir = "c", file = "hashtable.c"},
  {done = false, dir = "c", file = "queue.c"},
  {done = false, dir = "c", file = "trie.c"},
  {done = false, dir = "c", file = "boxhull.c"},
  {done = false, dir = "c", file = "areanode.c"},
  {done = false, dir = "c", file = "cdaudioeject.c"},
}

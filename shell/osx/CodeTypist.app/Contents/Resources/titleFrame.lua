local lyr = lt.Layer()

local l, r, t, b = lt.config.world_left, lt.config.world_right, lt.config.world_top, lt.config.world_bottom

--top logo
local hdr_lyr = lt.Layer()
local header =
  _txt("CODE TYPIST")
  :Scale(config.head_scl)
  :Translate(0, config.margin.top)

local subheader =
  _txt_base1("Typing Practice for Hackers")
  :Scale(config.subhead_scl)
  :Translate(0, config.margin.top - 0.2)

local url =
    _txt(config.codetypist_web)
    :Tint(unpack(config.white))
    :Scale(config.pnl_title_scl)
    :Translate(2.3, config.margin.top - 0.2)

hdr_lyr:Insert(lt.Rect(l, t - 0.5, r, t):Tint(unpack(config.sol_base02)))
hdr_lyr:Insert(header)
hdr_lyr:Insert(subheader)
hdr_lyr:Insert(url)

lyr:Insert(hdr_lyr)

return lyr

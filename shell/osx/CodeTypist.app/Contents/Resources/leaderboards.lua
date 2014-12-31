function submit_score(data, cb)
  local msg = lt.ToJSON(data)
  local req = lt.HTTPRequest(config.submit_score_url, msg)
  -- req.data = msg
  main_scene:Action(function(dt)
    req:Poll()
    if req.success then
      cb()
      return true
    elseif req.failure then
      log("Failed to submit score")
    end
  end)
end

function request_high_score(cb)
  local lang = string.lower(config.lang_opts.sel_lang)
  local file = string.lower(lang_sel_file())
  local url = config.high_score_url .. lang .. "/" .. file
  local req = lt.HTTPRequest(url)
  main_scene:Action(function(dt)
    req:Poll()
    if req.success then
      local result = lt.FromJSON(req.response)
      cb(result)
      return true
    elseif req.failure then
      log("Failed to update high scores")
    end
  end)
end

function update_scores_ui(parent)
  request_high_score(function(result)

    if #result == 0 then
      parent.child = lt.Text("Leaderboard Empty", fontui, "center", "center")
                      :Translate(0, -1.7):Scale(config.pnl_title_scl * 0.7)
      return
    end

    --sort the thing
    table.sort(result, function(s, k)
      return s.Wpm > k.Wpm
    end)

    local sy = 0.2
    local lyr = lt.Layer():Translate(-0.8, 0):Tint(unpack(config.silver))
    for num,v in ipairs(result) do
      local n_txt = lt.Text("".. num, fontui, "left", "center")
      local l_txt = lt.Text(string.upper(v.Player), fontui, "left", "center"):Tint(unpack(config.sol_base2))
      local wpm_txt = lt.Text("" .. v.Wpm, fontui, "right", "right")
      lyr:Insert(n_txt:Scale(config.pnl_title_scl * 0.7):Translate(0, sy))
      lyr:Insert(l_txt:Scale(config.pnl_title_scl * 0.7):Translate(0.15, sy))
      lyr:Insert(wpm_txt:Scale(config.pnl_title_scl * 0.7):Translate(1.6, sy))
      sy = sy - 0.15
    end
    parent.child = lyr
  end)
end

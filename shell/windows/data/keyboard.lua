function make_keyboard(cb)
    local keys = {
        {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"},
        {"Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"},
        {"A", "S", "D", "F", "G", "H", "J", "K", "L", "backspace"},
        {"Z", "X", "C", "V", "B", "N", "M", "enter"},
        {"cancel", "space"},
    }
    local chr_map = {
        {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"},
        {"Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"},
        {"A", "S", "D", "F", "G", "H", "J", "K", "L", "del"},
        {"Z", "X", "C", "V", "B", "N", "M", "enter", "enter", "enter"},
        {"esc", "esc", "space", "space", "space", "space", "space", "enter", "enter", "enter"},
    }
    local layer = lt.Layer()
    local kb_h, kb_w = (lt.top - lt.bottom) * 0.7, lt.right - lt.left
    local key_w, key_h = kb_w / #keys[1], kb_h / 5
    local gap = 0.06
    local x, y = lt.left, lt.bottom + kb_h
    local key_rect = lt.Rect(gap/2, -gap/2, key_w - gap, -key_h + gap):Tint(0.3, 0.3, 0.3)
    for _, row in ipairs(keys) do
        for _, key in ipairs(row) do
            if key == "space" then
                local space_rect = lt.Rect(gap/2, -gap/2, key_w * 5 - gap, -key_h + gap):Tint(0.3, 0.3, 0.3)
                layer:Insert(space_rect:Translate(x, y))
                x = x + key_w * 5
            elseif key == "backspace" then
                layer:Insert(key_rect:Translate(x, y))
                layer:Insert(lt.Text("DEL", font, "center", "center"):Scale(0.7):Translate(x + key_w/2, y - key_h/2))
                x = x + key_w
            elseif key == "cancel" then
                local cancel_rect = lt.Rect(gap/2, -gap/2, key_w * 2 - gap, -key_h + gap):Tint(0.3, 0.3, 0.3)
                layer:Insert(cancel_rect:Translate(x, y))
                layer:Insert(lt.Text("CANCEL", font, "center", "center"):Scale(0.8):Translate(x + key_w, y - key_h/2))
                x = x + key_w * 2
            elseif key == "enter" then
                local accept_rect = lt.Rect(gap/2, -gap/2, key_w * 3 - gap, -key_h * 2 + gap):Tint(0.3, 0.3, 0.3)
                layer:Insert(accept_rect:Translate(x, y))
                layer:Insert(lt.Text("ACCEPT", font, "center", "center"):Translate(x + key_w * 1.5, y - key_h))
                x = x + key_w * 3
            else
                layer:Insert(key_rect:Translate(x, y))
                layer:Insert(lt.Text(key, font, "center", "center"):Translate(x + key_w/2, y - key_h/2))
                x = x + key_w
            end
        end
        y = y - key_h
        x = lt.left
    end
    layer:PointerDown(function(event)
        if event.y < lt.bottom + kb_h then
            -- samples.uibleep:Play(1, lt.state.sfx_volume)
            samples.uibleep:Play(1, 1)
            local row = math.floor((1 - ((event.y - lt.bottom) / kb_h)) * 5) + 1
            local col = math.floor(((event.x - lt.left) / kb_w) * 10) + 1
            local chr = chr_map[row][col]
            cb(chr)
        end
    end)
    return layer
end

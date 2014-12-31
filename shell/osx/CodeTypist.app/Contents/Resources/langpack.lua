function lang_import_data()
  local lang = config.lang_opts.sel_lang
  for i,v in ipairs(config.data_packs[lang]) do
    if not v.done then
      config.lang_opts.sub_idx = i
      return import ("data/" .. v.dir .. "/" .. v.file)
    end
  end
  return import "data/LoremIpsum.txt"
end

function lang_mark_completed()
  local lang = config.lang_opts.sel_lang
  for _,v in ipairs(config.data_packs[lang]) do
    if not v.done then
      v.done = true
      return
    end
  end
end

function lang_mark_repeat()
  local lang = config.lang_opts.sel_lang
  local sub_idx = config.lang_opts.sub_idx
  config.data_packs[lang][sub_idx].done = false
end

function lang_sel_file()
  local lang = config.lang_opts.sel_lang
  local subidx = config.lang_opts.sub_idx
  return config.data_packs[lang][subidx].file
end

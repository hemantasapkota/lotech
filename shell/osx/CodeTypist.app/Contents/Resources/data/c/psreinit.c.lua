return [=[
int
ps_reinit(ps_decoder_t *ps, cmd_ln_t *config)
{
    const char *path;
    const char *keyphrase;
    int32 lw;

    if (config && config != ps->config) {
        cmd_ln_free_r(ps->config);
        ps->config = cmd_ln_retain(config);
    }

    err_set_debug_level(cmd_ln_int32_r(ps->config, ''-debug''));
    ps->mfclogdir = cmd_ln_str_r(ps->config, ''-mfclogdir'');
    ps->rawlogdir = cmd_ln_str_r(ps->config, ''-rawlogdir'');
    ps->senlogdir = cmd_ln_str_r(ps->config, ''-senlogdir'');

    ps_init_defaults(ps);

    ps_free_searches(ps);
    ps->searches = hash_table_new(3, HASH_CASE_YES);

    acmod_free(ps->acmod);
    ps->acmod = NULL;

    dict_free(ps->dict);
    ps->dict = NULL;

    dict2pid_free(ps->d2p);
    ps->d2p = NULL;

    if (ps->lmath == NULL
        || (logmath_get_base(ps->lmath) !=
            (float64)cmd_ln_float32_r(ps->config, ''-logbase''))) {
        if (ps->lmath)
            logmath_free(ps->lmath);
        ps->lmath = logmath_init
            ((float64)cmd_ln_float32_r(ps->config, ''-logbase''), 0,
             cmd_ln_boolean_r(ps->config, ''-bestpath''));
    }

     * uttproc.c, senscr.c, and others used to do) */
    if ((ps->acmod = acmod_init(ps->config, ps->lmath, NULL, NULL)) == NULL)
        return -1;

    if ((ps->pl_window = cmd_ln_int32_r(ps->config, ''-pl_window''))) {
        if ((ps->phone_loop =
             phone_loop_search_init(ps->config, ps->acmod, ps->dict)) == NULL)
            return -1;
        hash_table_enter(ps->searches,
                         ckd_salloc(ps_search_name(ps->phone_loop)),
                         ps->phone_loop);
    }

    if ((ps->dict = dict_init(ps->config, ps->acmod->mdef)) == NULL)
        return -1;
    if ((ps->d2p = dict2pid_build(ps->acmod->mdef, ps->dict)) == NULL)
        return -1;

    lw = cmd_ln_float32_r(config, ''-lw'');

    if ((keyphrase = cmd_ln_str_r(config, ''-keyphrase''))) {
        if (ps_set_keyphrase(ps, PS_DEFAULT_SEARCH, keyphrase))
            return -1;
        ps_set_search(ps, PS_DEFAULT_SEARCH);
    }

    if ((path = cmd_ln_str_r(config, ''-kws''))) {
        if (ps_set_kws(ps, PS_DEFAULT_SEARCH, path))
            return -1;
        ps_set_search(ps, PS_DEFAULT_SEARCH);
    }

    if ((path = cmd_ln_str_r(config, ''-fsg''))) {
        fsg_model_t *fsg = fsg_model_readfile(path, ps->lmath, lw);
        if (!fsg)
            return -1;
        if (ps_set_fsg(ps, PS_DEFAULT_SEARCH, fsg))
            return -1;
        ps_set_search(ps, PS_DEFAULT_SEARCH);
    }

    if ((path = cmd_ln_str_r(config, ''-jsgf''))) {
        if (ps_set_jsgf_file(ps, PS_DEFAULT_SEARCH, path)
            || ps_set_search(ps, PS_DEFAULT_SEARCH))
            return -1;
    }

    if ((path = cmd_ln_str_r(ps->config, ''-allphone''))) {
        if (ps_set_allphone_file(ps, PS_DEFAULT_SEARCH, path)
                || ps_set_search(ps, PS_DEFAULT_SEARCH))
                return -1;
    }

    if ((path = cmd_ln_str_r(ps->config, ''-lm'')) &&
        !cmd_ln_boolean_r(ps->config, ''-allphone'')) {
        if (ps_set_lm_file(ps, PS_DEFAULT_SEARCH, path)
            || ps_set_search(ps, PS_DEFAULT_SEARCH))
            return -1;
    }

    if ((path = cmd_ln_str_r(ps->config, ''-lmctl''))) {
        const char *name;
        ngram_model_t *lmset;
        ngram_model_set_iter_t *lmset_it;

        if (!(lmset = ngram_model_set_read(ps->config, path, ps->lmath))) {
            E_ERROR(''Failed to read language model control file: %s'', path);
            return -1;
        }

        for(lmset_it = ngram_model_set_iter(lmset);
            lmset_it; lmset_it = ngram_model_set_iter_next(lmset_it)) {

            ngram_model_t *lm = ngram_model_set_iter_model(lmset_it, &name);
            E_INFO(''adding search %s\n'', name);
            if (ps_set_lm(ps, name, lm)) {
                ngram_model_free(lm);
                ngram_model_set_iter_free(lmset_it);
                return -1;
            }
            ngram_model_free(lm);
        }

        name = cmd_ln_str_r(config, ''-lmname'');
        if (name)
            ps_set_search(ps, name);
        else {
            E_ERROR(''No default LM name (-lmname) for `-lmctl'\n'');
            return -1;
        }
    }

    ps->perf.name = ''decode'';
    ptmr_init(&ps->perf);

    return 0;
}
]=]

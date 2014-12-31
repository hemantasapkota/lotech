return [=[
int32
tmat_chk_uppertri(tmat_t * tmat, logmath_t *lmath)
{
    int32 i, src, dst;

    for (i = 0; i < tmat->n_tmat; i++) {
        for (dst = 0; dst < tmat->n_state; dst++)
            for (src = dst + 1; src < tmat->n_state; src++)
                if (tmat->tp[i][src][dst] < 255) {
                    E_ERROR(''tmat[%d][%d][%d] = %d'',
                            i, src, dst, tmat->tp[i][src][dst]);
                    return -1;
                }
    }

    return 0;
}

int32
tmat_chk_1skip(tmat_t * tmat, logmath_t *lmath)
{
    int32 i, src, dst;

    for (i = 0; i < tmat->n_tmat; i++) {
        for (src = 0; src < tmat->n_state; src++)
            for (dst = src + 3; dst <= tmat->n_state; dst++)
                if (tmat->tp[i][src][dst] < 255) {
                    E_ERROR(''tmat[%d][%d][%d] = %d'',
                            i, src, dst, tmat->tp[i][src][dst]);
                    return -1;
                }
    }

    return 0;
}
]=]

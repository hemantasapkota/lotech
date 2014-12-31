return [=[
int
acmod_end_utt(acmod_t *acmod)
{
    int32 nfr = 0;

    acmod->state = ACMOD_ENDED;
    if (acmod->n_mfc_frame < acmod->n_mfc_alloc) {
        int inptr;
        inptr = (acmod->mfc_outidx + acmod->n_mfc_frame) % acmod->n_mfc_alloc;
        fe_end_utt(acmod->fe, acmod->mfc_buf[inptr], &nfr);
        acmod->n_mfc_frame += nfr;

        if (nfr)
            nfr = acmod_process_mfcbuf(acmod);
        else
            feat_update_stats(acmod->fcb);
    }
    if (acmod->mfcfh) {
        long outlen;
        int32 rv;
        outlen = (ftell(acmod->mfcfh) - 4) / 4;
        if (!WORDS_BIGENDIAN)
            SWAP_INT32(&outlen);
        if ((rv = fseek(acmod->mfcfh, 0, SEEK_SET)) == 0) {
            fwrite(&outlen, 4, 1, acmod->mfcfh);
        }
        fclose(acmod->mfcfh);
        acmod->mfcfh = NULL;
    }
    if (acmod->rawfh) {
        fclose(acmod->rawfh);
        acmod->rawfh = NULL;
    }

    if (acmod->senfh) {
        fclose(acmod->senfh);
        acmod->senfh = NULL;
    }

    return nfr;
}
]=]

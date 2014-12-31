return [=[
void
ps_lattice_link(ps_lattice_t *dag, ps_latnode_t *from, ps_latnode_t *to,
                int32 score, int32 ef)
{
    latlink_list_t *fwdlink;

            break;

    if (fwdlink == NULL) {
        latlink_list_t *revlink;
        ps_latlink_t *link;

        link = listelem_malloc(dag->latlink_alloc);
        fwdlink = listelem_malloc(dag->latlink_list_alloc);
        revlink = listelem_malloc(dag->latlink_list_alloc);

        link->from = from;
        link->to = to;
        link->ascr = score;
        link->ef = ef;
        link->best_prev = NULL;

        fwdlink->link = revlink->link = link;
        fwdlink->next = from->exits;
        from->exits = fwdlink;
        revlink->next = to->entries;
        to->entries = revlink;
    }
    else {
        if (score BETTER_THAN fwdlink->link->ascr) {
            fwdlink->link->ascr = score;
            fwdlink->link->ef = ef;
        }
    }
}
]=]

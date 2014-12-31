return [=[
void SV_InitBoxHull (void)
{
    int             i;
    int             side;

    box_hull.clipnodes = box_clipnodes;
    box_hull.planes = box_planes;
    box_hull.firstclipnode = 0;
    box_hull.lastclipnode = 5;

    for (i=0 ; i<6 ; i++)
    {
        box_clipnodes[i].planenum = i;

        side = i&1;

        box_clipnodes[i].children[side] = CONTENTS_EMPTY;
        if (i != 5)
                box_clipnodes[i].children[side^1] = i + 1;
        else
                box_clipnodes[i].children[side^1] = CONTENTS_SOLID;

        box_planes[i].type = i>>1;
        box_planes[i].normal[i>>1] = 1;
    }
}
]=]

return [=[
areanode_t *SV_CreateAreaNode (int depth, vec3_t mins, vec3_t maxs)
{
      areanode_t      *anode;
      vec3_t          size;
      vec3_t          mins1, maxs1, mins2, maxs2;

      anode = &sv_areanodes[sv_numareanodes];
      sv_numareanodes++;

      ClearLink (&anode->trigger_edicts);
      ClearLink (&anode->solid_edicts);

      if (depth == AREA_DEPTH)
      {
              anode->axis = -1;
              anode->children[0] = anode->children[1] = NULL;
              return anode;
      }

      VectorSubtract (maxs, mins, size);
      if (size[0] > size[1])
              anode->axis = 0;
      else
              anode->axis = 1;

      anode->dist = 0.5 * (maxs[anode->axis] + mins[anode->axis]);
      VectorCopy (mins, mins1);
      VectorCopy (mins, mins2);
      VectorCopy (maxs, maxs1);
      VectorCopy (maxs, maxs2);

      maxs1[anode->axis] = mins2[anode->axis] = anode->dist;

      anode->children[0] = SV_CreateAreaNode (depth+1, mins2, maxs2);
      anode->children[1] = SV_CreateAreaNode (depth+1, mins1, maxs1);

      return anode;
}
]=]

return [=[
CMulticlassLabels* CDistanceMachine::apply_multiclass(CFeatures* data)
{
  if (data)
  {
    CFeatures* lhs=distance->get_lhs();
    distance->init(lhs, data);
    SG_UNREF(lhs);

    CMulticlassLabels* result=new CMulticlassLabels(data->get_num_vectors());
    for (index_t i=0; i<data->get_num_vectors(); ++i)
            result->set_label(i, apply_one(i));
    return result;
  }
  else
  {
    CFeatures* all=distance->get_rhs();
    CMulticlassLabels* result = apply_multiclass(all);
    SG_UNREF(all);
    return result;
  }
  return NULL;
}
]=]

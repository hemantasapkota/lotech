return [=[
- (void)getObjects:(id *)objects andKeys:(id *)keys
{
  NSParameterAssert((entry != NULL) && (count <= capacity));
  NSUInteger atEntry = 0UL; NSUInteger arrayIdx = 0UL;
  for(atEntry = 0UL; atEntry < capacity; atEntry++) {
    if(JK_EXPECT_T(entry[atEntry].key != NULL)) {
      NSCParameterAssert((entry[atEntry].object != NULL) && (arrayIdx < count));
      if(JK_EXPECT_T(keys    != NULL)) {
        keys[arrayIdx]    = entry[atEntry].key;
      }
      if(JK_EXPECT_T(objects != NULL)) {
        objects[arrayIdx] = entry[atEntry].object;
      }
      arrayIdx++;
    }
  }
}
]=]

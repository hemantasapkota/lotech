return [=[
- (void)reset
{
  for (FBTweakCategory *category in self.tweakCategories) {
    for (FBTweakCollection *collection in category.tweakCollections) {
      for (FBTweak *tweak in collection.tweaks) {
        if (!tweak.isAction) {
          tweak.currentValue = nil;
        }
      }
    }
  }
}
]=]

return [=[
class POPAnimatorItem
{
public:
  id __weak object;
  NSString *key;
  POPAnimation *animation;
  NSInteger refCount;
  id __unsafe_unretained unretainedObject;

  POPAnimatorItem(id o, NSString *k, POPAnimation *a) POP_NOTHROW
  {
    object = o;
    key = [k copy];
    animation = a;
    refCount = 1;
    unretainedObject = o;
  }

  ~POPAnimatorItem()
  {
  }

  bool operator==(const POPAnimatorItem& o) const {
    return unretainedObject == o.unretainedObject && animation == o.animation
    && [key isEqualToString:o.key];
  }
};
]=]

return [=[
function mixin(target, source, force, deepStringMixin) {
  if (source) {
      eachProp(source, function (value, prop) {
          if (force || !hasProp(target, prop)) {
              if (deepStringMixin && typeof value === 'object' && value &&
                  !isArray(value) && !isFunction(value) &&
                  !(value instanceof RegExp)) {

                  if (!target[prop]) {
                      target[prop] = {};
                  }
                  mixin(target[prop], value, force, deepStringMixin);
              } else {
                  target[prop] = value;
              }
          }
      });
  }
  return target;
}
]=]

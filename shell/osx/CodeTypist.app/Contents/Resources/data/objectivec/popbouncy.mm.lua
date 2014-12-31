return[[
double POPBouncy3NoBounce(double tension)
{
  double friction = 0;
  if (tension <= 18.) {
    friction = b3_friction1(tension);
  } else if (tension > 18 && tension <= 44) {
    friction = b3_friction2(tension);
  } else if (tension > 44) {
    friction = b3_friction3(tension);
  } else {
    assert(false);
  }
  return friction;
}
]]

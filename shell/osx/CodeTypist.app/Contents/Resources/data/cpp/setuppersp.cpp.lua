return [=[
void ofCamera::setupPerspective(bool _vFlip, float fov, float nearDist, float
farDist, const ofVec2f & lensOffset){
  ofRectangle orientedViewport = ofGetNativeViewport();
  float eyeX = orientedViewport.width / 2;
  float eyeY = orientedViewport.height / 2;
  float halfFov = PI * fov / 360;
  float theTan = tanf(halfFov);
  float dist = eyeY / theTan;

  if(nearDist == 0) nearDist = dist / 10.0f;
  if(farDist == 0) farDist = dist * 10.0f;

  setFov(fov);
  setNearClip(nearDist);
  setFarClip(farDist);
  setLensOffset(lensOffset);
  setForceAspectRatio(false);

  setPosition(eyeX,eyeY,dist);
  lookAt(ofVec3f(eyeX,eyeY,0),ofVec3f(0,1,0));
  vFlip = _vFlip;
}
]=]

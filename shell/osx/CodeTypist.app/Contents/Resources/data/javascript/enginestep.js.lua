return [=[
Engine.step = function step() {
  currentFrame++;
  nextTickFrame = currentFrame;

  var currentTime = Date.now();

  if (frameTimeLimit && currentTime - lastTime < frameTimeLimit) return;

  var i = 0;

  frameTime = currentTime - lastTime;
  lastTime = currentTime;

  eventHandler.emit('prerender');

  var numFunctions = nextTickQueue.length;
  while (numFunctions--) (nextTickQueue.shift())(currentFrame);

  while (deferQueue.length && (Date.now() - currentTime) <
         MAX_DEFER_FRAME_TIME) {
      deferQueue.shift().call(this);
  }

  for (i = 0; i < contexts.length; i++) contexts[i].update();

  eventHandler.emit('postrender');
};
]=]

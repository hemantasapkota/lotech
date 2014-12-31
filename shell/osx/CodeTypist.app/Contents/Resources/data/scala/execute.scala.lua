return [=[
override def execute() = {
  validateAttributes()
  val mapper = getMapper
  allEqualNow = true
  val originNames: Array[String] =
      getDirectoryScanner(origin.get).getIncludedFiles
  val bufferSize = 1024
  val originBuffer = new Array[Byte](bufferSize)
  val destBuffer = new Array[Byte](bufferSize)
  for (
    originName: String <- originNames;
    destName: String <- mapper.mapFileName(originName)
  ) {
    var equalNow = true
    val originFile = new File(origin.get, originName)
    val destFile = new File(destination.get, destName)
    if (originFile.canRead && destFile.canRead) {
      val originStream = new FileInputStream(originFile)
      val destStream = new FileInputStream(destFile)
      var originRemaining = originStream.read(originBuffer)
      var destRemaining = destStream.read(destBuffer)
      while (originRemaining > 0 && equalNow) {
        if (originRemaining == destRemaining)
          for (idx <- 0 until originRemaining)
            equalNow = equalNow && (originBuffer(idx) == destBuffer(idx))
        else
          equalNow = false
        originRemaining = originStream.read(originBuffer)
        destRemaining = destStream.read(destBuffer)
      }
      if (destRemaining > 0)
        equalNow = false
      if (!equalNow)
        reportDiff(originFile, destFile)
      originStream.close
      destStream.close
    }
    else reportMissing(originFile)
  }
  if (!allEqualNow)
    if (failing)
      sys.error(''There were differences between ''' + origin.get + ''' and '''
                + destination.get + ''''')
    else
      log(''There were differences between ''' + origin.get + ''' and ''' +
          destination.get + ''''')
  else {
    if (!resultProperty.isEmpty)
      getProject.setProperty(resultProperty.get, ''yes'')
    log(''All files in ''' + origin.get + ''' and ''' + destination.get + '''
        are equal'', Project.MSG_VERBOSE)
  }
}
]=]

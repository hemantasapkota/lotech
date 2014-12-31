return [=[
private var allEqualNow = true

private def validateAttributes() = {
  if (origin.isEmpty) sys.error(''Mandatory attribute 'dir' is not set.'')
  if (destination.isEmpty) sys.error(''Mandatory attribute 'todir' is not set.'')
}

private def reportDiff(f1: File, f2: File) = {
  allEqualNow = false
  log(''File ''' + f1 + ''' is different from correspondant.'')
}

private def reportMissing(f1: File) = {
  allEqualNow = false
  log(''File ''' + f1 + ''' has no correspondant.'')
}
]=]

return [[
private String buildCommand(Display display, Map<String,
String> prefs, IProject project, IResource resource, String
sourcePath, String outputPath) throws CoreException,
IOException {

  StringBuilder sb = new StringBuilder();

  Path(prefs.get(PreferenceConstants.PATH_TO_COMPILER))
    .append(PreferenceConstants.J2_OBJC_COMPILER);

  sb.append(pathToCompiler.toOSString()).append('' '');

  Properties classpathProps = PropertiesUtil.getClasspathEntries(project);

  if (!classpathProps.isEmpty()) {

    sb.append(PreferenceConstants.CLASSPAPTH).append('' '');

    for (Object key : classpathProps.keySet()) {

      sb.append(key).append('':''); } sb.append('' '');
    }

  if (StringUtils.isEmpty(prebuiltSwitch)) {

    prebuildSwitches(display, prefs, project);

  }

  sb.append(prebuiltSwitch);

  if (resource instanceof IFile) {
    String charset = ((IFile) resource).getCharset();

    sb.append(PreferenceConstants.ENCODING)
      .append('' '')
      .append(charset)
      .append('' '');
    }

  sb.append(PreferenceConstants.OUTPUT_DIR)
    .append('' '')
    .append(outputPath)
    .append('' '');

    sb.append(sourcePath);

  return sb.toString();
}
]]

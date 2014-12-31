return [=[
package scala.beans

abstract class ScalaBeanInfo(clazz: java.lang.Class[_],
                             props: Array[String],
                             methods: Array[String]) extends
                             java.beans.SimpleBeanInfo {

  import java.beans._

  private val pd = new Array[PropertyDescriptor](props.length / 3)
  private val md =
    for (m <- clazz.getMethods if methods.exists(_ == m.getName))
      yield new MethodDescriptor(m)

  init()

  override def getPropertyDescriptors() = pd
  override def getMethodDescriptors() = md

  private def init() {
    var i = 0
    while (i < props.length) {
      pd(i/3) = new PropertyDescriptor(props(i), clazz, props(i+1), props(i+2))
      i = i + 3
    }
  }
}
]=]

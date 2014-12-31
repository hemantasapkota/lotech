return [=[
trait Proxy extends Any {
  def self: Any

  override def hashCode: Int = self.hashCode
  override def equals(that: Any): Boolean = that match {
    case null  => false
    case _     =>
      val x = that.asInstanceOf[AnyRef]
      (x eq this.asInstanceOf[AnyRef]) || (x eq self.asInstanceOf[AnyRef]) ||
      (x equals self)
  }
  override def toString = "" + self
}

object Proxy {
  trait Typed[T] extends Any with Proxy {
    def self: T
  }
}
]=]

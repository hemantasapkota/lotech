return [=[
package scala

trait AnyRef extends Any {

  def equals(that: Any): Boolean = this eq that

  def hashCode: Int = sys.error(''hashCode'')

  def toString: String = sys.error(''toString'')

  def synchronized[T](body: => T): T

  final def eq(that: AnyRef): Boolean = sys.error(''eq'')

  final def ne(that: AnyRef): Boolean = !(this eq that)

  final def ==(that: Any): Boolean =
    if (this eq null) that.asInstanceOf[AnyRef] eq null
    else this equals that

  protected def clone(): AnyRef

  protected def finalize(): Unit

  def getClass(): Class[_]

  def notify(): Unit

  def notifyAll(): Unit

  def wait (): Unit
  def wait (timeout: Long, nanos: Int): Unit
  def wait (timeout: Long): Unit
}
]=]

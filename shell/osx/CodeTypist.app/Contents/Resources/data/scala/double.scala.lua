return [=[
final abstract class Double private extends AnyVal {
  def toByte: Byte
  def toShort: Short
  def toChar: Char
  def toInt: Int
  def toLong: Long
  def toFloat: Float
  def toDouble: Double

  def unary_+ : Double
  def unary_- : Double

  def +(x: String): String

  def ==(x: Byte): Boolean
  def ==(x: Short): Boolean
  def ==(x: Char): Boolean
  def ==(x: Int): Boolean
  def ==(x: Long): Boolean
  def ==(x: Float): Boolean
  def ==(x: Double): Boolean

  def !=(x: Byte): Boolean
  def !=(x: Short): Boolean
  def !=(x: Char): Boolean
  def !=(x: Int): Boolean
  def !=(x: Long): Boolean
  def !=(x: Float): Boolean
  def !=(x: Double): Boolean

  def <(x: Byte): Boolean
  def <(x: Short): Boolean
  def <(x: Char): Boolean
  def <(x: Int): Boolean
  def <(x: Long): Boolean
  def <(x: Float): Boolean
  def <(x: Double): Boolean

  def <=(x: Byte): Boolean
  def <=(x: Short): Boolean
  def <=(x: Char): Boolean
  def <=(x: Int): Boolean
  def <=(x: Long): Boolean
  def <=(x: Float): Boolean
  def <=(x: Double): Boolean

  def >(x: Byte): Boolean
  def >(x: Short): Boolean
  def >(x: Char): Boolean
  def >(x: Int): Boolean
  def >(x: Long): Boolean
  def >(x: Float): Boolean
  def >(x: Double): Boolean

  def >=(x: Byte): Boolean
  def >=(x: Short): Boolean
  def >=(x: Char): Boolean
  def >=(x: Int): Boolean
  def >=(x: Long): Boolean
  def >=(x: Float): Boolean
  def >=(x: Double): Boolean

  def +(x: Byte): Double
  def +(x: Short): Double
  def +(x: Char): Double
  def +(x: Int): Double
  def +(x: Long): Double
  def +(x: Float): Double
  def +(x: Double): Double

  def -(x: Byte): Double
  def -(x: Short): Double
  def -(x: Char): Double
  def -(x: Int): Double
  def -(x: Long): Double
  def -(x: Float): Double
  def -(x: Double): Double

  def *(x: Byte): Double
  def *(x: Short): Double
  def *(x: Char): Double
  def *(x: Int): Double
  def *(x: Long): Double
  def *(x: Float): Double
  def *(x: Double): Double

  def /(x: Byte): Double
  def /(x: Short): Double
  def /(x: Char): Double
  def /(x: Int): Double
  def /(x: Long): Double
  def /(x: Float): Double
  def /(x: Double): Double

  def %(x: Byte): Double
  def %(x: Short): Double
  def %(x: Char): Double
  def %(x: Int): Double
  def %(x: Long): Double
  def %(x: Float): Double
  def %(x: Double): Double

  override def getClass(): Class[Double] = null
}
]=]

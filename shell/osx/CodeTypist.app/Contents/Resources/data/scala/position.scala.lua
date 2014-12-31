return [=[
package scala
package io

@deprecated(''This class will be removed.'', ''2.10.0'')
private[scala] abstract class Position {
  def checkInput(line: Int, column: Int): Unit

  final val LINE_BITS   = 20
  final val COLUMN_BITS = 31 - LINE_BITS
  final val LINE_MASK   = (1 << LINE_BITS) - 1
  final val COLUMN_MASK = (1 << COLUMN_BITS) - 1

  final def encode(line: Int, column: Int): Int = {
    checkInput(line, column)

    if (line >= LINE_MASK)
      LINE_MASK << COLUMN_BITS
    else
      (line << COLUMN_BITS) | scala.math.min(COLUMN_MASK, column)
  }

  final def line(pos: Int): Int = (pos >> COLUMN_BITS) & LINE_MASK

  final def column(pos: Int): Int = pos & COLUMN_MASK

  def toString(pos: Int): String = line(pos) + '':'' + column(pos)
}

private[scala] object Position extends Position {
  def checkInput(line: Int, column: Int) {
    if (line < 0)
      throw new IllegalArgumentException(line + '' < 0'')
    if ((line == 0) && (column != 0))
      throw new IllegalArgumentException(line + '','' + column + '' not allowed'')
    if (column < 0)
      throw new IllegalArgumentException(line + '','' + column + '' not allowed'')
  }
}
]=]

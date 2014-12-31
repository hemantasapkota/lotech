return [=[
package scala
package collection

import generic._

trait BitSet extends SortedSet[Int]
                with BitSetLike[BitSet] {
  override def empty: BitSet = BitSet.empty
}

object BitSet extends BitSetFactory[BitSet] {
  val empty: BitSet = immutable.BitSet.empty
  def newBuilder = immutable.BitSet.newBuilder

  implicit def canBuildFrom: CanBuildFrom[BitSet, Int, BitSet] =
  bitsetCanBuildFrom
}
]=]

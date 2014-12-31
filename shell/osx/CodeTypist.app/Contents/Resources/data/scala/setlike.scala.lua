return [=[
package scala
package collection

import generic._
import mutable.{ Builder, SetBuilder }
import scala.annotation.{migration, bridge}
import parallel.ParSet

trait SetLike[A, +This <: SetLike[A, This] with Set[A]]
extends IterableLike[A, This]
   with GenSetLike[A, This]
   with Subtractable[A, This]
   with Parallelizable[A, ParSet[A]]
{
self =>

  def empty: This

  override protected[this] def newBuilder: Builder[A, This] = new SetBuilder[A,
        This](empty)

  protected[this] override def parCombiner = ParSet.newCombiner[A]

  override def toSeq: Seq[A] = toBuffer[A]
  override def toBuffer[A1 >: A]: mutable.Buffer[A1] = {
    val result = new mutable.ArrayBuffer[A1](size)
    copyToBuffer(result)
    result
  }

  @migration(''Set.map now returns a Set, so it will discard duplicate
  values.'', ''2.8.0'')
  override def map[B, That](f: A => B)(implicit bf: CanBuildFrom[This, B,
  That]): That = super.map(f)(bf)

  def contains(elem: A): Boolean

  def + (elem: A): This

  def + (elem1: A, elem2: A, elems: A*): This = this + elem1 + elem2 ++ elems

  def ++ (elems: GenTraversableOnce[A]): This = (repr /: elems.seq)(_ + _)

  def - (elem: A): This

  override def isEmpty: Boolean = size == 0

  def union(that: GenSet[A]): This = this ++ that

  def diff(that: GenSet[A]): This = this -- that

  def subsets(len: Int): Iterator[This] = {
    if (len < 0 || len > size) Iterator.empty
    else new SubsetsItr(self.toIndexedSeq, len)
  }

  def subsets: Iterator[This] = new AbstractIterator[This] {
    private val elms = self.toIndexedSeq
    private var len = 0
    private var itr: Iterator[This] = Iterator.empty

    def hasNext = len <= elms.size || itr.hasNext
    def next = {
      if (!itr.hasNext) {
        if (len > elms.size) Iterator.empty.next()
        else {
          itr = new SubsetsItr(elms, len)
          len += 1
        }
      }

      itr.next()
    }
  }

  private class SubsetsItr(elms: IndexedSeq[A], len: Int) extends
  AbstractIterator[This] {
    private val idxs = Array.range(0, len+1)
    private var _hasNext = true
    idxs(len) = elms.size

    def hasNext = _hasNext
    def next(): This = {
      if (!hasNext) Iterator.empty.next()

      val buf = self.newBuilder
      idxs.slice(0, len) foreach (idx => buf += elms(idx))
      val result = buf.result()

      var i = len - 1
      while (i >= 0 && idxs(i) == idxs(i+1)-1) i -= 1

      if (i < 0) _hasNext = false
      else {
        idxs(i) += 1
        for (j <- (i+1) until len)
          idxs(j) = idxs(j-1) + 1
      }

      result
    }
  }
  override def stringPrefix: String = ''Set''
  override def toString = super[IterableLike].toString
}
]=]

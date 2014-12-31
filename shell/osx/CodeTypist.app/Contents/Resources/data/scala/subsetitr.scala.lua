return [=[
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
]=]

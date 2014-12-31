return [=[
func (points PointList) Compute() (PointList, bool) {
  if len(points) < 3 {
    return nil, false
  }

  stack := new(Stack)
  points.FindLowestPoint()
  sort.Sort(&points)

  stack.Push(points[0])
  stack.Push(points[1])

  i := 2
  for i < len(points) {
    pi := points[i]

    p1 := stack.top.next.value.(Point)
    p2 := stack.top.value.(Point)

    if isLeft(p1, p2, pi) {
      stack.Push(pi)
      i++
    } else {
      stack.Pop()
    }
  }

  ret := make(PointList, stack.Len())
  top := stack.top
  count := 0
  for top != nil {
    ret[count] = top.value.(Point)
    top = top.next
    count++
  }

  return ret, true
}
]=]

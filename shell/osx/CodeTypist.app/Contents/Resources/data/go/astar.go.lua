return [=[
package astar

import ''container/heap''

type Pather interface {
  PathNeighbors() []Pather
  PathNeighborCost(to Pather) float64
  PathEstimatedCost(to Pather) float64
}

type node struct {
  pather Pather
  cost   float64
  rank   float64
  parent *node
  open   bool
  closed bool
  index  int
}

type nodeMap map[Pather]*node

func (nm nodeMap) get(p Pather) *node {
  n, ok := nm[p]
  if !ok {
    n = &node{
            pather: p,
    }
    nm[p] = n
  }
  return n
}

func Path(from, to Pather) (path []Pather, distance float64, found bool) {
  nm := nodeMap{}
  nq := &priorityQueue{}
  heap.Init(nq)
  fromNode := nm.get(from)
  fromNode.open = true
  heap.Push(nq, fromNode)
  for {
    if nq.Len() == 0 {
      return
    }
    current := heap.Pop(nq).(*node)
    current.open = false
    current.closed = true
    for _, neighbor := range current.pather.PathNeighbors() {
      cost := current.cost + current.pather.PathNeighborCost(neighbor)
      neighborNode := nm.get(neighbor)
      if neighbor == to {
        p := []Pather{}
        curr := neighborNode
        curr.parent = current
        for curr != nil {
          p = append(p, curr.pather)
          curr = curr.parent
        }
        return p, cost, true
      }
      if cost < neighborNode.cost {
        if neighborNode.open {
                heap.Remove(nq, neighborNode.index)
        }
        neighborNode.open = false
        neighborNode.closed = false
      }
      if !neighborNode.open && !neighborNode.closed {
        neighborNode.cost = cost
        neighborNode.open = true
        neighborNode.rank = cost + neighbor.PathEstimatedCost(to)
        neighborNode.parent = current
        heap.Push(nq, neighborNode)
      }
    }
  }
}
]=]

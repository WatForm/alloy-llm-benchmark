sig Node {}

one sig Root in Node {}

one sig HeapState {
  left: Node -> lone Node,
  right: Node -> lone Node,
  marked: set Node,
  freeList: lone Node
}

pred clearMarks[h, h': HeapState] {
  h'.left = h.left
  h'.right = h.right
  no h'.marked
  h'.freeList = h.freeList
}

fun reachable[h: HeapState, start: Node]: set Node {
  start.*((h.left) + (h.right))
}

pred mark[h, h': HeapState, start: Node] {
  h'.left = h.left
  h'.right = h.right
  h'.freeList = h.freeList
  h'.marked = reachable[h, start]
}

pred setFreeList[h, h': HeapState] {
  h'.marked = h.marked
  all n: Node | n in h.marked implies (h'.left[n] = h.left[n] and h'.right[n] = h.right[n])

  let unmarked = Node - h.marked |
    (
      no unmarked implies {
        no h'.freeList
        all n: unmarked | no h'.left[n] and no h'.right[n]
      }
      else {
        h'.freeList in unmarked
        unmarked = h'.freeList.*(h'.left)
        all n: unmarked | no h'.right[n]
      }
    )
}

fact GCHappened {
  some hc, hm: HeapState |
    clearMarks[HeapState, hc] and
    mark[hc, hm, Root] and
    setFreeList[hm, HeapState]
}

run {} for 6
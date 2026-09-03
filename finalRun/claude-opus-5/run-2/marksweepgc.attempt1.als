sig Node {}

sig HeapState {
	left, right: Node -> lone Node,
	marked: set Node,
	freeList: lone Node
}

one sig h, hsn in HeapState {}

one sig root in Node {}

pred clearMarks [hs, hs': HeapState] {
	no hs'.marked
	hs'.left = hs.left
	hs'.right = hs.right
}

fun reachable [hs: HeapState, from: Node] : set Node {
	from.*(hs.left + hs.right)
}

pred mark [hs: HeapState, from: Node, hs': HeapState] {
	hs'.marked = reachable[hs, from]
	hs'.left = hs.left
	hs'.right = hs.right
}

pred setFreeList [hs, hs': HeapState] {
	hs'.freeList.*(hs'.left) in Node - hs.marked
	all n: Node - hs.marked {
		no n.(hs'.right)
		n.(hs'.left) in hs'.freeList.*(hs'.left)
		n in hs'.freeList.*(hs'.left)
	}
	all n: hs.marked {
		n.(hs'.left) = n.(hs.left)
		n.(hs'.right) = n.(hs.right)
	}
	hs'.marked = hs.marked
}

fact {
	some hs, hs': HeapState |
		clearMarks[h, hs] and mark[hs, root, hs'] and setFreeList[hs', hsn]
}
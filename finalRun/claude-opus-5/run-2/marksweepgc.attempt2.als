sig Node {}

sig HeapState {
	left, right: Node -> lone Node,
	marked: set Node,
	freeList: lone Node
}

one sig h, hsn in HeapState {}

one sig root in Node {}

pred clearMarks [hs, hs1: HeapState] {
	no hs1.marked
	hs1.left = hs.left
	hs1.right = hs.right
}

fun reachable [hs: HeapState, from: Node] : set Node {
	from.*(hs.left + hs.right)
}

pred mark [hs: HeapState, from: Node, hs1: HeapState] {
	hs1.marked = reachable[hs, from]
	hs1.left = hs.left
	hs1.right = hs.right
}

pred setFreeList [hs, hs1: HeapState] {
	hs1.freeList.*(hs1.left) in Node - hs.marked
	all n: Node - hs.marked {
		no n.(hs1.right)
		n.(hs1.left) in hs1.freeList.*(hs1.left)
		n in hs1.freeList.*(hs1.left)
	}
	all n: hs.marked {
		n.(hs1.left) = n.(hs.left)
		n.(hs1.right) = n.(hs.right)
	}
	hs1.marked = hs.marked
}

fact {
	some hs1, hs2: HeapState |
		clearMarks[h, hs1] and mark[hs1, root, hs2] and setFreeList[hs2, hsn]
}
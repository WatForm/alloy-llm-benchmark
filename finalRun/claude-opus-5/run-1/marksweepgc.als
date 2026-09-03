module chapter6/marksweepgc

sig Node {}

sig HeapState {
	left, right : Node -> lone Node,
	marked : set Node,
	freeList : lone Node
}

one sig h, hsn in HeapState {}

one sig root in Node {}

pred clearMarks [hs, hs2 : HeapState] {
	no hs2.marked
	hs2.left = hs.left
	hs2.right = hs.right
}

fun reachable [hs : HeapState, n : Node] : set Node {
	n.*(hs.left + hs.right)
}

pred mark [hs : HeapState, from : Node, hs2 : HeapState] {
	hs2.marked = reachable[hs, from]
	hs2.left = hs.left
	hs2.right = hs.right
}

pred setFreeList [hs, hs2 : HeapState] {
	(hs2.freeList).*(hs2.left) in Node - hs.marked
	all n : Node - hs.marked {
		no n.(hs2.right)
		n.(hs2.left) in (hs2.freeList).*(hs2.left)
		n in (hs2.freeList).*(hs2.left)
	}
	all n : hs.marked {
		n.(hs2.left) = n.(hs.left)
		n.(hs2.right) = n.(hs.right)
	}
	hs2.marked = hs.marked
}

fact {
	some h1, h2 : HeapState {
		clearMarks[h, h1]
		mark[h1, root, h2]
		setFreeList[h2, hsn]
	}
}
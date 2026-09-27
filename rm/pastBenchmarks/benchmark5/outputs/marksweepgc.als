sig Node {}

sig HeapState {
	left: Node -> lone Node,
	right: Node -> lone Node,
	marked: set Node,
	freeList: lone Node
}

one sig h, hsn in HeapState {}

one sig root extends Node {}

pred clearMarks[beforeState, afterState: HeapState] {
	no afterState.marked
	beforeState.left = afterState.left
	beforeState.right = afterState.right
}

fun reachable[heapState: HeapState, from: Node]: set Node {
	from.*(heapState.left + heapState.right)
}

pred mark[beforeState: HeapState, from: Node, afterState: HeapState] {
	afterState.marked = reachable[beforeState, from]
	afterState.left = beforeState.left
	afterState.right = beforeState.right
}

pred setFreeList[beforeState, afterState: HeapState] {
	afterState.freeList.*(afterState.left) in Node - beforeState.marked

	all n: Node - beforeState.marked | {
		no n.(afterState.right)
		n.(afterState.left) in afterState.freeList.*(afterState.left)
		n in afterState.freeList.*(afterState.left)
	}

	all n: beforeState.marked | {
		n.(afterState.left) = n.(beforeState.left)
		n.(afterState.right) = n.(beforeState.right)
	}

	afterState.marked = beforeState.marked
}

fact {
	some hs1, hs2: HeapState | {
		clearMarks[h, hs1]
		mark[hs1, root, hs2]
		setFreeList[hs2, hsn]
	}
}
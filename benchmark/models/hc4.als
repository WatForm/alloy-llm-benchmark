module hc4	

abstract sig Vertex {
	left: lone Vertex,
	right: lone Vertex
}
sig Joint extends Vertex {}
sig End extends Vertex {}

fact {
	all e: End |
		(e.left = none and e = e.right.left) or
		(e.right = none and e = e.left.right)
}

fact {
	all j: Joint |
		j = j.left.right and 
		j = j.right.left and 
		j.left != j.right
}

fact {
	all v: Vertex |
		Vertex - v = v.(^left + ^right)
}

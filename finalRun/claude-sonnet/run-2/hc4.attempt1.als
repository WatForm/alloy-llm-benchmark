abstract sig Vertex {
  left: lone Vertex,
  right: lone Vertex
}

sig Joint extends Vertex {}
sig End extends Vertex {}

fact EndFact {
  all e: End |
    (no e.left and e = e.right.left)
    or
    (no e.right and e = e.left.right)
}

fact JointFact {
  all j: Joint |
    j.left.right = j and
    j.right.left = j and
    j.left != j.right
}

fact ReachabilityFact {
  all v: Vertex | Vertex - v = v.^left + v.^right
}
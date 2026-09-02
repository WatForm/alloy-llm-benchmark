sig Vertex {
  left: lone Vertex,
  right: lone Vertex
}

sig Joint extends Vertex {}
sig End extends Vertex {}

fact {
  Vertex = Joint + End

  all e: End |
    (no e.left and e = e.right.left) or
    (no e.right and e = e.left.right)

  all j: Joint |
    j.left.right = j and
    j.right.left = j and
    j.left != j.right

  all v: Vertex |
    v.^left + v.^right = Vertex - v
}
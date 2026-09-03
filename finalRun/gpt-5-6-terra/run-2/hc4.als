sig Vertex {
  left: lone Vertex,
  right: lone Vertex
}

sig Joint, End in Vertex {}

fact {
  no Joint & End
  Vertex = Joint + End

  all e: End |
    (no e.left and e = e.right.left) or
    (no e.right and e = e.left.right)

  all j: Joint | {
    j.left.right = j
    j.right.left = j
    j.left != j.right
  }

  all v: Vertex | {
    Vertex - v = v.^left + v.^right
    v not in v.^left + v.^right
  }
}
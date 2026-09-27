sig Vertex {
  left: lone Vertex,
  right: lone Vertex
}

sig Joint, End extends Vertex {}

fact Partition {
  Vertex = Joint + End
}

fact EndConstraints {
  all e: End |
    (
      some e.left and no e.right and e = e.left.right
    ) or
    (
      some e.right and no e.left and e = e.right.left
    )
}

fact JointConstraints {
  all j: Joint |
    some j.left and some j.right and
    j.left != j.right and
    j = j.left.right and
    j = j.right.left
}

fact Connected {
  all v: Vertex | Vertex - v in v.^(left + right)
}

fun neighbors[v: Vertex]: set Vertex {
  v.left + v.right
}

pred show {
  #Vertex > 0
}

run show for 5 Vertex
abstract sig Vertex {
  left: lone Vertex,
  right: lone Vertex
}

sig Joint extends Vertex {}
sig End extends Vertex {}

fact Ends {
  all e: End |
    (
      no e.left and some e.right and e in e.right.left
    ) or (
      some e.left and no e.right and e in e.left.right
    )
}

fact Joints {
  all j: Joint |
    some j.left and some j.right and
    j in j.left.right and
    j in j.right.left and
    j.left != j.right
}

fun neighbors[v: Vertex]: set Vertex {
  v.left + v.right
}

fact Connected {
  all v: Vertex |
    Vertex - v = v.^(left + right)
}

pred show {
  #Vertex > 0
}

run show for 5
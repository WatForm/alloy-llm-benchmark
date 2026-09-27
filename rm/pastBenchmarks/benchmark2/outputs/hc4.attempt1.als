sig Vertex {
  left: lone Vertex,
  right: lone Vertex
}

sig End, Joint extends Vertex {}

fact EndConstraint {
  all e: End |
    (some e.right and no e.left and e in e.right.left) or
    (some e.left and no e.right and e in e.left.right)
}

fact JointConstraint {
  all j: Joint |
    some j.left and some j.right and
    j.left != j.right and
    j in j.left.right and
    j in j.right.left
}

fact Partition {
  Vertex = End + Joint
}

fact Connectivity {
  all v: Vertex | Vertex - v in v.^(left + right)
}
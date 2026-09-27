abstract sig Vertex {
  left, right : lone Vertex
}

sig Joint, End extends Vertex {}

fact EndProperties {
  all e : End |
    (no e.left and e = e.right.left)
    or (no e.right and e = e.left.right)
}

fact JointProperties {
  all j : Joint |
    j.left.right = j
    and j.right.left = j
    and j.left != j.right
}

fact Reachability {
  all v : Vertex |
    Vertex - v = v.^left + v.^right
}
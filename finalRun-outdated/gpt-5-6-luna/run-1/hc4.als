sig Vertex {
    left: lone Vertex,
    right: lone Vertex
}

sig Joint, End extends Vertex {}

fact {
    Vertex = Joint + End

    all e: End |
        (no e.left and e.right.left = e) or
        (no e.right and e.left.right = e)

    all j: Joint |
        j.left.right = j and
        j.right.left = j and
        j.left != j.right

    all v: Vertex |
        v.^left + v.^right = Vertex - v
}
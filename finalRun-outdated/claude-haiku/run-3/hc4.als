sig Vertex {
  left: lone Vertex,
  right: lone Vertex
}

sig Joint, End in Vertex {}

fact {
  no (Joint & End)
  Joint + End = Vertex
}

fact {
  all e: End {
    (no e.left and e = e.right.left) or
    (no e.right and e = e.left.right)
  }
}

fact {
  all j: Joint {
    j.left.right = j and
    j.right.left = j and
    j.left != j.right
  }
}

fact {
  all v: Vertex {
    (Vertex - v) = (v.^left + v.^right)
  }
}
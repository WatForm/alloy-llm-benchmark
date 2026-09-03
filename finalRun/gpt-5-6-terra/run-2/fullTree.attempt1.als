sig Node {
  left: set Node,
  right: set Node
}

fact {
  (all n: Node | lone n.left and lone n.right) and
  no (iden & ^(left + right)) and
  (all n: Node | lone n.~(left + right)) and
  (all n: Node | no (n.left & n.right)) and
  (all n: Node |
    (no n.left and no n.right) or
    (one n.left and one n.right)
  ) and
  (all n: Node | #(n.*left) = #(n.*right))
}
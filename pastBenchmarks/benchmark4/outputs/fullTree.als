sig Node {
  left: set Node,
  right: set Node
}

fact {
  all n: Node | lone n.left
  all n: Node | lone n.right
}

fact {
  no n: Node | n in n.^(left + right)
}

fact {
  all n: Node | lone ((Node - n) & n.~(left + right))
}

fact {
  all n: Node | no n.left & n.right
}

fact {
  let child = left + right |
    ((some Node) implies (one root: Node | Node = root.*child))
    and (all n: Node | (no n.child) or (one n.left and one n.right))
    and (all l1, l2: Node |
      ((no l1.child and no l2.child) implies (#(l1.^(~child)) = #(l2.^(~child)))))
}

fact {
  all n: Node | #(n.*left) = #(n.*right)
}
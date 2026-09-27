sig Node {
  left: set Node,
  right: set Node
}

fact {
  all n: Node | {
    lone n.left
    lone n.right
    no n.left & n.right
  }

  no iden & ^(left + right)

  all n: Node | lone (left + right).n

  all n: Node |
    (no n.left and no n.right) or
    (one n.left and one n.right)

  let e = left + right |
    all r: Node |
      no e.r implies
        all l1, l2: r.*e |
          (no l1.e and no l2.e) implies
            #{n: Node | n in r.*e and l1 in n.*e} =
            #{n: Node | n in r.*e and l2 in n.*e}

  all n: Node |
    #(n.*left) = #(n.*right)
}
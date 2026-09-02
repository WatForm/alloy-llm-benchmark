sig Node {
  left: set Node,
  right: set Node
}

fact {
  all n: Node | lone n.left
  all n: Node | lone n.right

  no iden & ^(left + right)

  all n: Node | lone (left + right).n

  all n: Node | no n.left & n.right

  all n: Node |
    no n.(left + right) or
    (one n.left and one n.right)

  all r: Node |
    no (left + right).r implies
      all l1, l2: r.*(left + right) |
        (no l1.(left + right) and no l2.(left + right)) implies
          #(l1.^(~(left + right))) = #(l2.^(~(left + right)))

  all n: Node |
    #(n.*left) = #(n.*right)
}
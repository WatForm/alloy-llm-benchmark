sig Node {
  left: lone Node,
  right: lone Node
}

pred acyclic {
  no iden & (left + right)^+
}

pred singleParent {
  all n: Node | lone (~left.n + ~right.n)
}

pred disjointLeftRight {
  all n: Node | no (n.left & n.right)
}

pred perfectBinaryForest {
  all n: Node | (some n.left iff some n.right)
}

pred equalReachability {
  all n: Node | #(n.*(left)) = #(n.*(right))
}

fact {
  acyclic and singleParent and disjointLeftRight and perfectBinaryForest and equalReachability
}
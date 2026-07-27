module FullTree

sig Node {
  left: set Node,
  right: set Node
}

fact {
  all n : Node| lone n.left && lone n.right
}

fact Acyclic {
  all n : Node {
    n !in n.^(left + right) 
    lone n.~(left + right) 
    no n.left & n.right 
  }
}

fact makeFull {
  all n : Node | #(n.*left) = #(n.*right)
}

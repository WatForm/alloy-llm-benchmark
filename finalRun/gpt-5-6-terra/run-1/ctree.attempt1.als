abstract sig Color {}

one sig Red, Blue extends Color {}

sig Node {
  neighbors: set Node,
  color: one Color
}

fact {
  all n: Node | n not in n.neighbors
  all n: Node | all m: Node | m in n.neighbors iff n in m.neighbors
  all n, m: Node | m in n.*neighbors
  no s: set Node | some s and all n: s | #(n.neighbors & s) >= 2
}
module ins

sig Record {}

abstract sig Label {}

sig Node {
  label: one Label
}

sig LabelTree {
  root: one Node,
  nodes: set Node,
  children: nodes -> nodes
} {
  root in nodes
  some root.(children)
  nodes in root.*children
}

sig Attribute extends Label {}
sig Value extends Label {}
one sig Wildcard, Null extends Value {}

sig AVTree extends LabelTree {
  vnodes: set nodes,
  anodes: set nodes
} {
  root in anodes and root in vnodes
  vnodes + anodes = nodes
  all n: nodes |
    all disj c1, c2: n.children |
      c1.label != c2.label
  all n: anodes | n.children in vnodes
  all n: vnodes | n.children in anodes
}

one sig Query extends AVTree {}
one sig Advertisement extends AVTree {}

one sig DB extends AVTree {
  records: set Record,
  recs: nodes -> records
} {
  no (vnodes & label.Wildcard)
  no (anodes <: recs)
}

sig State {
  conforms: Query -> Advertisement -> Node -> Node,
  lookup: Query -> DB -> Node -> Record
}

pred Get[d: DB, r: Record, a: Advertisement] {
  r in d.records
  some n: d.vnodes & a.vnodes | n->r in d.recs
}

pred ConformsAux[q: Query, a: Advertisement, nq: Node, na: Node] {
  nq in q.nodes
  na in a.nodes
  nq->na in q.root.*(q.children) -> a.root.*(a.children)
  all cq: nq.(q.children) |
    some ca: na.(a.children) |
      ConformsAux[q, a, cq, ca]
}

pred Conforms[q: Query, a: Advertisement] {
  ConformsAux[q, a, q.root, a.root]
}

fun LookupAux[q: Query, d: DB, nq: Node]: set Record {
  { r: d.records |
    some nd: d.nodes |
      nq->nd in (q.root.*(q.children) -> d.root.*(d.children)) and
      nd->r in d.recs
  }
}

fun Lookup[q: Query, d: DB]: set Record {
  LookupAux[q, d, q.root]
}

fact ConformsFixPoint {
  all s: State, q: Query, a: Advertisement, nq: q.nodes, na: a.nodes |
    nq->na in s.conforms[q][a] implies
      (nq.label = Wildcard or nq.label = na.label)
}

fact LookupFixPoint {
  all s: State, q: Query, d: DB, r: Record |
    r in s.lookup[q][d] iff
      r in Lookup[q, d]
}

assert LookupConforms2 {
  all s: State, q: Query, a: Advertisement, d: DB, r: Record |
    Conforms[q, a] and Get[d, r, a] implies r in s.lookup[q][d]
}

check LookupConforms2 for 6 but 10 Node, 10 Label, 10 Record, 6 LabelTree, 6 State
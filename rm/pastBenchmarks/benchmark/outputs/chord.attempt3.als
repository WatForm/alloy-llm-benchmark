module chord_lookup

open util/ordering[Id] as Ord

sig Id {
  next: one Id
}

sig Node {
  id: one Id
}

sig NodeData {
  prev: one Node,
  next: one Node,
  finger: Id -> lone Node,
  closest_preceding_finger: Id -> one Node,
  find_predecessor: Id -> one Node,
  find_successor: Id -> one Node
}

sig State {
  active: set Node,
  data: Node -> lone NodeData
}

fun activeIds[s: State]: set Id { s.active.id }

pred betweenOpen[a, b, x: Id] {
  x in a.^Id$next and x in b.^~(Id$next)
}

pred betweenOpenClosed[a, b, x: Id] {
  x = b or betweenOpen[a, b, x]
}

pred betweenClosedOpen[a, b, x: Id] {
  x = a or betweenOpen[a, b, x]
}

fun succNode[s: State, i: Id]: one Node {
  { n: s.active | i in n.id.*~(Id$next) and no m: s.active - n | m.id in i.*~(Id$next) and n.id in m.id.^(Id$next) }
}

fun predNode[s: State, i: Id]: one Node {
  { n: s.active | n.id in i.*~(Id$next) and no m: s.active - n | m.id in i.*~(Id$next) and m.id in n.id.^(Id$next) }
}

fun firstAtOrAfter[s: State, i: Id]: one Node { succNode[s, i] }

fun lastBefore[s: State, i: Id]: one Node { predNode[s, i] }

fact RingIds {
  all i: Id | Id = i.*(Id$next)
}

fact NextMatchesOrdering {
  all i: Id |
    (i != Ord/last implies i.next = Ord/next[i]) and
    (i = Ord/last implies i.next = Ord/first)
}

fact DistinctNodeIds {
  all disj n1, n2: Node | n1.id != n2.id
}

fact NonEmptyActive {
  all s: State | some s.active
}

fact DataTyping {
  all s: State | s.data[Node] = s.active
}

fact DataUnique {
  all s: State, disj n1, n2: s.active | s.data[n1] != s.data[n2]
}

pred NextCorrect[s: State] {
  all n: s.active |
    s.data[n].next = firstAtOrAfter[s, n.id.next]
}

pred NextCorrectP[s: State] {
  all n: s.active |
    s.data[n].next = succNode[s, n.id.next]
}

pred FingersCorrect[s: State] {
  all n: s.active, i: Id |
    s.data[n].finger[i] = firstAtOrAfter[s, i]
}

pred FingersCorrectP[s: State] {
  all n: s.active |
    s.data[n].finger[n.id.next] = s.data[n].next
}

pred ClosestPrecedingFinger[s: State] {
  all n: s.active, target: Id |
    let nd = s.data[n] |
      (some m: nd.finger[Id] | betweenOpen[n.id, target, m.id]) implies
        betweenOpen[n.id, target, nd.closest_preceding_finger[target].id]
}

pred ClosestPrecedingFingerP[s: State] {
  all n: s.active, target: Id |
    let nd = s.data[n] |
      (no m: nd.finger[Id] | betweenOpen[n.id, target, m.id]) implies
        nd.closest_preceding_finger[target] = n
}

pred FindPredecessor[s: State] {
  all n: s.active, target: Id |
    s.data[n].find_predecessor[target] = predNode[s, target]
}

pred FindPredecessorP[s: State] {
  all n: s.active, target: Id |
    let p = s.data[n].find_predecessor[target] |
      betweenClosedOpen[p.id, p.id.next, target]
}

pred FindSuccessor[s: State] {
  all n: s.active, target: Id |
    s.data[n].find_successor[target] = succNode[s, target]
}

fact PrevNextConsistency {
  all s: State, n: s.active |
    s.data[n].prev = predNode[s, n.id] and
    s.data[n].next = succNode[s, n.id.next]
}

fact FunctionalRelations {
  all s: State, n: s.active |
    one s.data[n].prev and
    one s.data[n].next and
    all i: Id |
      one s.data[n].closest_preceding_finger[i] and
      one s.data[n].find_predecessor[i] and
      one s.data[n].find_successor[i]
}

fact ChordCorrectness {
  all s: State |
    NextCorrect[s] and
    NextCorrectP[s] and
    FingersCorrect[s] and
    FingersCorrectP[s] and
    ClosestPrecedingFinger[s] and
    ClosestPrecedingFingerP[s] and
    FindPredecessor[s] and
    FindPredecessorP[s] and
    FindSuccessor[s]
}

pred ShowMeFC {
  some s: State | FingersCorrect[s]
}

pred ShowMeCPF {
  some s: State | ClosestPrecedingFinger[s]
}

pred SameFP {
  all s: State, n: s.active, i: Id |
    s.data[n].find_successor[i] = s.data[s.data[n].find_predecessor[i]].next
}

assert SuccessorFromPredecessor {
  all s: State, n: s.active, i: Id |
    s.data[n].find_successor[i] = succNode[s, i]
}

assert NextIsFinger0 {
  all s: State, n: s.active |
    s.data[n].next = s.data[n].finger[n.id.next]
}

assert NodeIdsUnique {
  all disj n1, n2: Node | n1.id != n2.id
}

check SuccessorFromPredecessor for 6 but exactly 1 State
check NextIsFinger0 for 6 but exactly 1 State
check NodeIdsUnique for 6

run ShowMeFC for 6 but 3 Node, exactly 1 State
run ShowMeCPF for 6 but 3 Node, exactly 1 State
run SameFP for 6 but 4 Node, exactly 1 State
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
  data: active -> one NodeData
}

fun succs[i: Id]: set Id { i.^next }

pred betweenOpen[a, b, x: Id] {
  a != b and x in a.^next and x in b.^~next
}

pred betweenOpenClosed[a, b, x: Id] {
  x = b or betweenOpen[a, b, x]
}

pred betweenClosedOpen[a, b, x: Id] {
  x = a or betweenOpen[a, b, x]
}

fun activeIds[s: State]: set Id { s.active.id }

fun succNode[s: State, i: Id]: one Node {
  { n: s.active | i in n.id.*next and no (s.active - n).id & i.*next } 
}

fun predNode[s: State, i: Id]: one Node {
  { n: s.active | n.id in i.*~next and no (s.active - n).id & n.id.^next & i.*~next }
}

fun firstAtOrAfter[s: State, i: Id]: one Node {
  succNode[s, i]
}

fun lastBefore[s: State, i: Id]: one Node {
  predNode[s, i]
}

fact RingIds {
  all i: Id | Id = i.*next
}

fact NextMatchesOrdering {
  all i: Id | i.next = Ord/next[i] else Ord/first
}

fact DistinctNodeIds {
  all disj n1, n2: Node | n1.id != n2.id
}

fact NonEmptyActive {
  all s: State | some s.active
}

fact DataDomain {
  all s: State | s.data.NodeData = s.active
}

fact DataUnique {
  all s: State, disj n1, n2: s.active | s.data[n1] != s.data[n2]
}

pred NextCorrect[s: State] {
  all n: s.active |
    s.data[n].next = firstAtOrAfter[s, n.id.next]
}

pred NextCorrect'[s: State] {
  all n: s.active |
    s.data[n].next = succNode[s, n.id]
}

pred FingersCorrect[s: State] {
  all n: s.active, i: Id |
    lone s.data[n].finger[i] and
    s.data[n].finger[i] = firstAtOrAfter[s, i]
}

pred FingersCorrect'[s: State] {
  all n: s.active |
    s.data[n].finger[n.id.next] = s.data[n].next
}

pred ClosestPrecedingFinger[s: State] {
  all n: s.active, target: Id |
    let nd = s.data[n] |
      (some m: s.active | m in nd.finger[Id] and betweenOpen[n.id, target, m.id]) implies
        nd.closest_preceding_finger[target] in { m: s.active | m in nd.finger[Id] and betweenOpen[n.id, target, m.id] } and
        no m: s.active |
          m in nd.finger[Id] and
          betweenOpen[n.id, target, m.id] and
          nd.closest_preceding_finger[target].id in m.id.^next & target.^~next
}

pred ClosestPrecedingFinger'[s: State] {
  all n: s.active, target: Id |
    let nd = s.data[n] |
      (no m: s.active | m in nd.finger[Id] and betweenOpen[n.id, target, m.id]) implies
        nd.closest_preceding_finger[target] = n
}

pred FindPredecessor[s: State] {
  all n: s.active, target: Id |
    s.data[n].find_predecessor[target] = predNode[s, target]
}

pred FindPredecessor'[s: State] {
  all n: s.active, target: Id |
    let p = s.data[n].find_predecessor[target] |
      betweenClosedOpen[p.id, p.id.next, target] or target = p.id.next
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
    NextCorrect'[s] and
    FingersCorrect[s] and
    FingersCorrect'[s] and
    ClosestPrecedingFinger[s] and
    ClosestPrecedingFinger'[s] and
    FindPredecessor[s] and
    FindPredecessor'[s] and
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
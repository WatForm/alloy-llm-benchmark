module chord

sig Id {
  next: one Id
}

fact IdRing {
  all i: Id | Id in i.^next
}

sig Node {
  id: lone Id
}

fact UniqueNodeIds {
  all disj n1, n2: Node |
    some n1.id and some n2.id implies n1.id != n2.id
}

sig NodeData {
  prev: lone Node,
  next: lone Node,
  finger: Id -> lone Node,
  closest_preceding_finger: Id -> lone Node,
  find_predecessor: Id -> lone Node,
  find_successor: Id -> lone Node
}

sig State {
  active: set Node,
  data: active -> one NodeData
}

pred less_than[start, a, b: Id] {
  a != b
  b in a.^next
  a in start.*next
  b in start.*next
}

fun succs[s: State, n: Node]: set Node {
  n.^(s.data.next)
}

pred OrderedFrom[s: State, start, a, b: Node] {
  some start.id and some a.id and some b.id
  less_than[start.id, a.id, b.id]
}

pred NextCorrect[s: State, n: Node] {
  n in s.active
  some n.id
  one s.data[n].next
  let nn = s.data[n].next |
    nn in s.active and
    some nn.id and
    (
      (#s.active = 1 and nn = n) or
      (#s.active > 1 and
        nn != n and
        all m: s.active - n |
          some m.id implies (m = nn or less_than[n.id, nn.id, m.id]))
    )
}

pred PrevCorrect[s: State, n: Node] {
  n in s.active
  one s.data[n].prev
  let p = s.data[n].prev |
    p in s.active and
    some p.id and some n.id and
    s.data[p].next = n
}

pred FingersCorrect[s: State, n: Node] {
  n in s.active
  some n.id
  all i: Id |
    one s.data[n].finger[i] and
    let f = s.data[n].finger[i] |
      f in s.active and
      some f.id and
      (
        f.id = i or
        i in f.id.^next
      ) and
      all m: s.active |
        some m.id implies
          (m = f or not (f.id = i or i in m.id.^next))
}

pred ClosestPrecedingFingerCorrect[s: State, n: Node] {
  n in s.active
  some n.id
  all target: Id |
    let cpf = s.data[n].closest_preceding_finger[target] |
      lone cpf and
      (some cpf implies cpf in s.active and some cpf.id and less_than[n.id, cpf.id, target]) and
      all m: s.active |
        some m.id and less_than[n.id, m.id, target] implies
          (some cpf and (m = cpf or less_than[n.id, m.id, cpf.id] or m.id = cpf.id))
}

pred FindPredecessorCorrect[s: State, n: Node] {
  n in s.active
  all target: Id |
    one s.data[n].find_predecessor[target] and
    let p = s.data[n].find_predecessor[target] |
      p in s.active and
      some p.id and
      one s.data[p].next and
      some s.data[p].next.id and
      (
        target = s.data[p].next.id or
        target in p.id.^next and
        s.data[p].next.id in target.*next
      )
}

pred FindSuccessorCorrect[s: State, n: Node] {
  n in s.active
  all target: Id |
    one s.data[n].find_successor[target] and
    s.data[n].find_successor[target] = s.data[s.data[n].find_predecessor[target]].next
}

pred WellFormedState[s: State] {
  all n: s.active |
    one s.data[n] and
    some n.id
  all n: Node - s.active | no s.data[n]
  all n: s.active | NextCorrect[s, n]
  all n: s.active | PrevCorrect[s, n]
  all n: s.active | FingersCorrect[s, n]
  all n: s.active | ClosestPrecedingFingerCorrect[s, n]
  all n: s.active | FindPredecessorCorrect[s, n]
  all n: s.active | FindSuccessorCorrect[s, n]
}

assert InjectiveIds {
  all disj n1, n2: Node |
    some n1.id and some n2.id implies n1.id != n2.id
}

assert FindSuccessorWorks {
  all s: State |
    WellFormedState[s] implies
    all n: s.active, target: Id |
      s.data[n].find_successor[target] = s.data[s.data[n].find_predecessor[target]].next
}

assert NextPointersFormRing {
  all s: State |
    WellFormedState[s] implies
    all n: s.active | s.active in n.^(s.data.next)
}

assert PrevNextConsistent {
  all s: State |
    WellFormedState[s] implies
    all n: s.active |
      s.data[s.data[n].prev].next = n and
      s.data[s.data[n].next].prev = n
}

pred ShowMe {
  some s: State | WellFormedState[s]
}

pred ShowMe2 {
  one s: State |
    #s.active = 3 and
    WellFormedState[s]
}

pred ShowMe3 {
  one s: State |
    #s.active = 2 and
    WellFormedState[s]
}

pred ShowMe4 {
  one s: State |
    #s.active = 4 and
    WellFormedState[s]
}

run ShowMe for 5 but 5 Id, 5 Node, 5 NodeData, 2 State
run ShowMe2 for 3 but 3 Id, 3 Node, 3 NodeData, 1 State
run ShowMe3 for 2 but 2 Id, 2 Node, 2 NodeData, 1 State
run ShowMe4 for 4 but 4 Id, 4 Node, 4 NodeData, 1 State

check InjectiveIds for 6
check FindSuccessorWorks for 6
check NextPointersFormRing for 6
check PrevNextConsistent for 6
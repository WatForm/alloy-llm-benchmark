sig Seg {
  next: one Seg,
  overlap: set Seg
} {
  this in overlap
  overlap = ~overlap
}

sig Train {}

sig GateState {
  closed: set Seg
}

sig TrainState {
  on: Train -> lone Seg,
  occupied: set Seg
} {
  occupied = Train.(on)
}

fun contains[ts: TrainState, s: Seg]: set Train {
  s.~(ts.on)
}

pred Safe[ts: TrainState] {
  all s: Seg | lone contains[ts, s.overlap]
}

pred MayMove[ts: TrainState, gs: GateState] {
  no (ts.occupied & gs.closed)
}

pred TrainsMove[ts, ts': TrainState, moved: set Train] {
  all t: moved |
    some ts.on[t] implies ts'.on[t] in ts.on[t].next
  all t: Train - moved |
    ts'.on[t] = ts.on[t]
}

pred GatePolicy[ts: TrainState, gs: GateState] {
  all s: ts.occupied.overlap | s.next in gs.closed
  lone { s: Seg | some other: Seg - s | s.next in other.next.overlap }
}

assert PolicyWorks {
  all ts, ts': TrainState, gs: GateState, moved: set Train |
    MayMove[ts, gs] and
    TrainsMove[ts, ts', moved] and
    Safe[ts] and
    GatePolicy[ts, gs]
    implies Safe[ts']
}

pred TrainsMoveLegal[ts, ts': TrainState, gs: GateState, moved: set Train] {
  MayMove[ts, gs]
  TrainsMove[ts, ts', moved]
}

check PolicyWorks for 5 expect 1
run TrainsMoveLegal for 5 expect 1
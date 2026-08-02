sig Seg {
  next: set Seg,
  overlaps: set Seg
} {
  this in overlaps
  all s: Seg | s in overlaps iff this in s.overlaps
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

fun contain[s: Seg, ts: TrainState]: set Train {
  s.~(ts.on)
}

pred Safe[ts: TrainState] {
  all s: Seg | lone contain[s.overlaps, ts]
}

pred MayMove[g: GateState, ts: TrainState, tr: set Train] {
  no (tr.(ts.on) & g.closed)
}

pred TrainsMove[ts, ts': TrainState, tr: set Train] {
  all t: tr | ts'.on[t] = ts.on[t].next
  all t: Train - tr | ts'.on[t] = ts.on[t]
}

pred GatePolicy[g: GateState, ts: TrainState] {
  all s: ts.occupied | s.overlaps.next in g.closed
  lone ((Seg.next & (Seg.next).~overlaps) + (Seg.next - overlaps.(Seg.next)))
}

assert PolicyWorks {
  all ts, ts': TrainState, g: GateState, tr: set Train |
    MayMove[g, ts, tr] and
    TrainsMove[ts, ts', tr] and
    Safe[ts] and
    GatePolicy[g, ts]
    implies Safe[ts']
}

pred TrainsMoveLegal {
  some ts, ts': TrainState, g: GateState, tr: set Train |
    MayMove[g, ts, tr] and
    TrainsMove[ts, ts', tr] and
    Safe[ts] and
    GatePolicy[g, ts]
}

check PolicyWorks for 4 but 2 TrainState, 1 GateState expect 1
run TrainsMoveLegal for 4 but 2 TrainState, 1 GateState expect 1
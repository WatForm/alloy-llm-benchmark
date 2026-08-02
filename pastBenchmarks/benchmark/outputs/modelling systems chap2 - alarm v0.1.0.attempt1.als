sig Condition {}

sig Sensor {
  raises: set Condition
}

sig Qualification {
  conds: some Condition
} {
  all q: Qualification - this | q.conds != conds
}

sig Expert {
  quals: set Qualification
}

sig State {
  called_experts: set Expert,
  onsite_experts: set Expert,
  current_alarms: set Condition
}

pred can_solve_all_alarms[e: Expert, alarms: set Condition] {
  alarms in e.quals.conds
}

pred called_experts_check[s: State] {
  all a: s.current_alarms |
    some e: s.onsite_experts + s.called_experts | can_solve_all_alarms[e, a]

  no (s.called_experts & s.onsite_experts)

  all e: s.called_experts |
    let remaining = s.onsite_experts + (s.called_experts - e) |
      some a: s.current_alarms | no ex: remaining | can_solve_all_alarms[ex, a]
}

run {
  all e: Expert | e in State.called_experts + State.onsite_experts
  some State.current_alarms
  called_experts_check[State]
} for 2 but exactly 1 State, exactly 0 Sensor
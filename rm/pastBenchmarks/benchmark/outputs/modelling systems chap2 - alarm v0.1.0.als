sig Condition {}

sig Sensor {
  raises: set Condition
}

sig Qualification {
  conds: some Condition
} {
  all q: Qualification - this | q.@conds != this.@conds
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
  s.current_alarms in (s.onsite_experts + s.called_experts).quals.conds
  no (s.called_experts & s.onsite_experts)
  all e: s.called_experts |
    not (s.current_alarms in (s.onsite_experts + (s.called_experts - e)).quals.conds)
}

run {
  one s: State |
    Expert in s.called_experts + s.onsite_experts
    and some s.current_alarms
    and called_experts_check[s]
} for 2 but exactly 1 State, exactly 0 Sensor
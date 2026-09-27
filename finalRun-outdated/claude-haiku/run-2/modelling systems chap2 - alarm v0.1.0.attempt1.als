sig Condition {}

sig Sensor {
  raise_alarm_on: set Condition
}

sig Qualification {
  conditions: some Condition
}

sig Expert {
  qualifications: some Qualification
}

sig State {
  called_experts: set Expert,
  onsite_experts: set Expert,
  current_alarms: set Condition
}

fact qualifications_unique {
  all disj q1, q2: Qualification |
    q1.conditions != q2.conditions
}

fact no_overlap {
  all s: State |
    no (s.called_experts & s.onsite_experts)
}

fact all_states_can_solve {
  all s: State |
    s.current_alarms in (s.onsite_experts + s.called_experts).qualifications.conditions
}

fact no_unnecessary_called_experts {
  all s: State, e: s.called_experts |
    s.current_alarms not in (s.onsite_experts + (s.called_experts - e)).qualifications.conditions
}
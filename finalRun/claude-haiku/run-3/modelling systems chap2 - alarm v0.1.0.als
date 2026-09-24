abstract sig Condition {}

abstract sig Sensor {
  raise_alarm_on: set Condition
}

abstract sig Qualification {
  conditions: some Condition
}

abstract sig Expert {
  qualifications: some Qualification
}

abstract sig State {
  called_experts: set Expert,
  onsite_experts: set Expert,
  current_alarms: set Condition
}

fact qualificationUniqueness {
  all q1, q2: Qualification | q1 != q2 => q1.conditions != q2.conditions
}

fact expertDisjoint {
  all s: State | no (s.called_experts & s.onsite_experts)
}

fact canSolveAlarms {
  all s: State | s.current_alarms in (s.onsite_experts.qualifications.conditions + s.called_experts.qualifications.conditions)
}

fact minimalCalledExperts {
  all s: State, e: s.called_experts | s.current_alarms not in ((s.onsite_experts + (s.called_experts - e)).qualifications.conditions)
}
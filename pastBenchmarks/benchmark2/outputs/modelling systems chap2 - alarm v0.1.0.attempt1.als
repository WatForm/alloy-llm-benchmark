sig Condition {}

sig Sensor {
  raise_alarm_on: set Condition
}

sig Qualification {
  covers: some Condition
} {
  all q: Qualification - this | q.covers != covers
}

sig Expert {
  qualifications: some Qualification
}

sig State {
  called: set Expert,
  onsite: set Expert,
  current_alarms: set Condition
}

pred can_solve_all_alarms[e: Expert, cs: set Condition] {
  cs in e.qualifications.covers
}

pred called_experts_check[s: State] {
  s.current_alarms in (s.onsite + s.called).qualifications.covers
  all e: s.called |
    not (s.current_alarms in ((s.onsite + s.called) - e).qualifications.covers)
}

fact CalledExpertscheck {
  all s: State | called_experts_check[s]
}
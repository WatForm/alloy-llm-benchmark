sig Condition {}

sig Sensor {
  raise_alarm_on : set Condition
}

sig Qualification {
  conditions : set Condition
}

sig Expert {
  qualifications : set Qualification
}

sig State {
  called_experts : set Expert,
  onsite_experts : set Expert,
  current_alarms : set Condition
}

fact NonEmptyConditions {
  all q : Qualification | some q.conditions
}

fact DistinctQualificationConditions {
  all disj q1, q2 : Qualification | q1.conditions != q2.conditions
}

fact NonEmptyQualifications {
  all e : Expert | some e.qualifications
}

fact AlarmsSolvable {
  all s : State |
    s.current_alarms in (s.onsite_experts + s.called_experts).qualifications.conditions
}

fact NoExpertInBoth {
  all s : State | no s.called_experts & s.onsite_experts
}

fact CalledExpertsNecessary {
  all s : State |
    all e : s.called_experts |
      s.current_alarms not in
        (s.onsite_experts + (s.called_experts - e)).qualifications.conditions
}
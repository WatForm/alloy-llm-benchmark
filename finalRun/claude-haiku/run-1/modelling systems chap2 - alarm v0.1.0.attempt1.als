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

fact unique_qualification_conditions {
    all q1, q2: Qualification | q1 != q2 implies q1.conditions != q2.conditions
}

fact can_solve_all_alarms {
    all s: State |
        s.current_alarms in (s.onsite_experts + s.called_experts).qualifications.conditions
}

fact no_overlap_experts {
    all s: State | no (s.called_experts & s.onsite_experts)
}

fact called_experts_minimal {
    all s: State |
        all e: s.called_experts |
            some alarm: s.current_alarms |
                alarm not in (s.onsite_experts + (s.called_experts - e)).qualifications.conditions
}
sig Condition {}

sig Sensor {
    raise_alarm_on: set Condition
}

sig Qualification {
    conditions: set Condition
}

sig Expert {
    qualifications: set Qualification
}

sig State {
    called_experts: set Expert,
    onsite_experts: set Expert,
    current_alarms: set Condition
}

fact QualificationUniqueness {
    all q1, q2: Qualification | 
        q1 != q2 implies (q1.conditions != q2.conditions)
}

fact StateAlarmSolving {
    all s: State |
        s.current_alarms in (set c: Condition | 
            some e: Expert | 
                e in s.onsite_experts and c in e.qualifications.conditions) or 
        s.current_alarms in (set c: Condition | 
            some e: Expert | 
                e in s.called_experts and c in e.qualifications.conditions)
}

fact NoDualExperts {
    all s: State, e: Expert |
        e in s.called_experts implies e !in s.onsite_experts
}

fact NecessaryCalledExperts {
    all s: State, e: Expert |
        e in s.called_experts implies 
        not (s.current_alarms in (set c: Condition | 
            (s.current_alarms - c) in (set c2: Condition |
                some e2: Expert | 
                    e2 in s.called_experts and c2 in e2.qualifications.conditions)))
}
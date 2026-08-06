sig Condition {}

sig Sensor {
	raise_alarm_on : set Condition
}

sig Qualification {
	conditions : some Condition
}

sig Expert {
	qualifications : some Qualification
}

sig State {
	called_experts : set Expert,
	onsite_experts : set Expert,
	current_alarms : set Condition
}

fact different_qualifications {
	all disj q1, q2 : Qualification | q1.conditions != q2.conditions
}

fact solve_all_alarms {
	all s : State |
		s.current_alarms in (s.onsite_experts + s.called_experts).qualifications.conditions
}

fact disjoint_experts {
	all s : State | no s.called_experts & s.onsite_experts
}

fact no_unnecessary_called_experts {
	all s : State, e : s.called_experts |
		not s.current_alarms in (s.onsite_experts + (s.called_experts - e)).qualifications.conditions
}
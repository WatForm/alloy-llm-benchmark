sig Condition
{
}

sig Sensor
{
	raise_alarm_on : set Condition
}

sig Qualification
{
	conditions: some Condition
}
{
	no Q : Qualification-this | Q.@conditions = conditions
}

sig Expert
{
	qualifications : some Qualification
}

sig State
{
  called_experts: set Expert,
  onsite_experts: set Expert,
  current_alarms: set Condition
}

pred can_solve_all_alarms[ Es:Expert, Cs:Condition ]
{
	Cs in conditions[ qualifications[Es] ]
}

pred called_experts_check[ S: State ]
{
	can_solve_all_alarms[ onsite_experts[S] + called_experts[S], current_alarms[S] ]
  no called_experts[S] & onsite_experts[S]
	no E: called_experts[S] | can_solve_all_alarms[ onsite_experts[S] + (called_experts[S] - E), current_alarms[S] ]
}

fact CalledExpertscheck {
    all s: State | called_experts_check[s]
}

sig Field {
}

sig Game {
where: one Field,
when: one Date

}

sig Date {
}

one sig FieldComplex{
schedule: set Game
}


fact NotOnSchedule{
//Games *not* on the schedule have no associated field or date.
some g: Game| g not in FieldComplex.schedule => no  g.where + g.when 
}

fact OnSchedule{
some g: Game| g in FieldComplex.schedule => #g.where =1 and #g.when=1
//Games that *are* on the schedule have one field and one date.
}

fact SameField{
//Games on the same field are scheduled for different dates.
all disj g1, g2 : Game | (g1.where = g2.where) => (g1.when !=g2.when)

}
//In addition to the facts, the model must have the following run predicates:

pred ScheduledGame{
//at least one Game is on the FieldComplex schedule with a Date and Field.
some g : Game| g in FieldComplex.schedule => #g.when=1 and #g.where=1
}

pred UnscheduledGame{
//at least one Game is not scheduled.
some g:Game| g not  in FieldComplex.schedule 
}
//Use the following run command to explore the state space of the static model:
run{
ScheduledGame
	UnscheduledGame
} for 5

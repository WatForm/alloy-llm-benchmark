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
some g: Game| g not in FieldComplex.schedule => no  g.where + g.when 
}

fact OnSchedule{
some g: Game| g in FieldComplex.schedule => #g.where =1 and #g.when=1
}

fact SameField{
all disj g1, g2 : Game | (g1.where = g2.where) => (g1.when !=g2.when)

}


pred ScheduledGame{

some g : Game| g in FieldComplex.schedule => #g.when=1 and #g.where=1
}

pred UnscheduledGame{

some g:Game| g not  in FieldComplex.schedule 
}

fact {
ScheduledGame
	UnscheduledGame
}

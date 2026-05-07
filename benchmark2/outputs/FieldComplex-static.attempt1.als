sig Field {}

sig Date {}

sig Game {
  field: lone Field,
  date: lone Date
}

one sig FieldComplex {
  schedule: set Game
}

fact NotOnSchedule {
  all g: Game - FieldComplex.schedule | no g.field and no g.date
}

fact OnSchedule {
  all g: FieldComplex.schedule | one g.field and one g.date
}

fact SameField {
  all disj g1, g2: Game |
    g1.field = g2.field implies g1.date != g2.date
}

pred ScheduledGame {
  some f: Field, d: Date |
    some g: FieldComplex.schedule | g.field = f and g.date = d
}

pred UnscheduledGame {
  some g: Game | g not in FieldComplex.schedule
}

run { ScheduledGame and UnscheduledGame }
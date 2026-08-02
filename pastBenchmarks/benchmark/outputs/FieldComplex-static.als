sig Field {}

sig Date {}

sig Game {
  where: lone Field,
  when: lone Date
}

one sig FieldComplex {
  schedule: set Game
}

fact NotOnSchedule {
  all g: Game | g not in FieldComplex.schedule implies no g.where and no g.when
}

fact OnSchedule {
  all g: Game | g in FieldComplex.schedule implies one g.where and one g.when
}

fact SameField {
  all g1, g2: Game |
    g1 != g2 and g1.where = g2.where implies g1.when != g2.when
}

pred ScheduledGame {
  some g: Game | g in FieldComplex.schedule and one g.where and one g.when
}

pred UnscheduledGame {
  some g: Game | g not in FieldComplex.schedule
}

run { ScheduledGame and UnscheduledGame } for 5
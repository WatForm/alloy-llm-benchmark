sig Person {}

sig Student, Professor extends Person {}

sig Class {
  assistants: set Student,
  instructor: one Professor
}

sig Assignment {
  clazz: one Class,
  assignedTo: some Student
}

pred PolicyAllowsGrading[p: Person, a: Assignment] {
  p in a.clazz.assistants + a.clazz.instructor
}

fact NoSelfGrading {
  all p: Person, a: Assignment |
    PolicyAllowsGrading[p, a] implies p not in a.assignedTo
}
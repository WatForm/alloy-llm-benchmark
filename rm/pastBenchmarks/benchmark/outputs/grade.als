abstract sig Person {}
sig Student, Professor extends Person {}

sig Class {
  instructor_of: one Professor,
  assistant_for: set Student
}

sig Assignment {
  associated_with: one Class,
  assigned_to: set Student
}

pred PolicyAllowsGrading[p: Person, a: Assignment] {
  p in a.associated_with.assistant_for + a.associated_with.instructor_of
}

assert NoOneCanGradeTheirOwnAssignment {
  all p: Person, a: Assignment |
    PolicyAllowsGrading[p, a] implies p not in a.assigned_to
}

check NoOneCanGradeTheirOwnAssignment
abstract sig Person {}

sig Student extends Person {}

sig Professor extends Person {}

sig Class {
  assistant_for: set Student,
  instructor_of: one Professor
}

sig Assignment {
  associated_with: one Class,
  assigned_to: some Student
}

pred canGrade[p: Person, a: Assignment] {
  p in a.associated_with.assistant_for or p = a.associated_with.instructor_of
}

fact GradingConstraint {
  all p: Person, a: Assignment | canGrade[p, a] implies p not in a.assigned_to
}
sig Person {}

sig Student extends Person {}

sig Professor extends Person {}

fact StudentProfessorPartition {
  Person = Student + Professor
  no Student & Professor
}

sig Class {
  assistant_for: set Student,
  instructor_of: one Professor
}

sig Assignment {
  associated_with: one Class,
  assigned_to: some Student
}

fact PersonClassAssignmentDisjoint {
  no Person & Class
  no Person & Assignment
  no Class & Assignment
}

pred canGrade[p: Person, a: Assignment] {
  p in a.associated_with.assistant_for or p = a.associated_with.instructor_of
}

fact GraderNotAssigned {
  all p: Person, a: Assignment |
    canGrade[p, a] implies not (p in Student and p in a.assigned_to)
}
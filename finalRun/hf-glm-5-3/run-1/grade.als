// Model of classes, assignments, and grading

abstract sig Person {}

sig Student, Professor extends Person {}

sig Class {
    assistant_for: set Student,
    instructor_of: one Professor
}

sig Assignment {
    associated_with: one Class,
    assigned_to: some Student
}

// A person can grade an assignment if they are an assistant for the
// class the assignment is associated with, or the instructor of that class.
pred canGrade[p: Person, a: Assignment] {
    p in a.associated_with.assistant_for
    or
    p = a.associated_with.instructor_of
}

// If a person can grade an assignment, then that person is not
// a student assigned to that assignment.
fact gradingConstraint {
    all p: Person, a: Assignment |
        canGrade[p, a] implies p not in a.assigned_to
}
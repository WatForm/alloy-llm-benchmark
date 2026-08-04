sig Person {}

sig Student extends Person {}

sig Professor extends Person {}

sig Class {
    assistant_for: set Student,
    instructor_of: Professor
}

sig Assignment {
    associated_with: Class,
    assigned_to: set Student
}

pred canGrade(p: Person, a: Assignment) {
    p in a.associated_with.assistant_for or
    p = a.associated_with.instructor_of
}

fact NoGradingAssigned {
    all p: Person, a: Assignment | canGrade(p, a) implies p !in a.assigned_to
}
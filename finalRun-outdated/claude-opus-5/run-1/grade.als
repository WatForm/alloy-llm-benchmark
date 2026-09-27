abstract sig Person {}

sig Student extends Person {}

sig Professor extends Person {}

sig Class {
	assistant_for : set Student,
	instructor_of : one Professor
}

sig Assignment {
	associated_with : one Class,
	assigned_to : some Student
}

pred can_grade[p : Person, a : Assignment] {
	p in a.associated_with.assistant_for or p = a.associated_with.instructor_of
}

fact {
	all p : Person, a : Assignment |
		can_grade[p, a] implies p not in a.assigned_to
}
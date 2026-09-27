There are disjoint sets called "Person", "Class", and "Assignment".

"Person" is partitioned into the subsets "Student" and "Professor", and every "Person" is either a "Student" or a "Professor".

Each "Class" has an "assistant_for" relation to a set of "Student" elements. 
A class may have any number of students in "assistant_for", including none. 
Each "Class" has an "instructor_of" relation to exactly one "Professor".

Each "Assignment" has an "associated_with" relation to exactly one "Class". 
Each "Assignment" has an "assigned_to" relation to one or more "Student" elements.

A person can grade an assignment if the person is
(1) an "assistant_for" the class "associated_with" with the assignment; 
or 
(2) the professor who is the "instructor_of" the class "associated_with" with the assignment.

For every "Person" and every "Assignment", if the person can grade an assignment then  that person is not a student "assigned_to" that assignment.

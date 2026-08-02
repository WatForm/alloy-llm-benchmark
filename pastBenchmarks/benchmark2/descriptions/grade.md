The model describes a system that contains people, classes, students, professors, and assignments.

In this model, Person is a type of entity and Student and Professor are sub-types of Person. The relationship between these three entities is that every Student or Professor is also a Person, but not every Person has to be a Student or Professor.

A Class in this system is a type of entity that has relationships with Students and Professors. Each Class can have zero or more Students who are assistants for the class. It is possible for a class to not have any student assistants. Each Class is also related to exactly one Professor who is the instructor of the class.

An Assignment in this system is a type of entity that is associated with a Class and is assigned to one or more Students. Every Assignment has to be associated with exactly one Class and assigned to at least one Student.

The model has a predicate called PolicyAllowsGrading which checks if a given Person (either a Student or Professor) is allowed to grade a given Assignment. This predicate checks if the Person is either an assistant for the Class associated with the Assignment or the instructor of the Class associated with the Assignment.

The model also has a fact which constrains the system in a way that no Person can grade their own Assignment. This is defined such that, for every Person and every Assignment, if the PolicyAllowsGrading predicate returns true for that Person and that Assignment, then that Person cannot be one of the Students the Assignment is assigned to.
This Alloy model comprises four signature: "Avenant", "Modification", "ModifiedEntity", and "Date".

- "Avenant" has a field called "modifications", which is a set of "Modification".

- "Modification" contains two fields: "modified_entity", which can optionally contain one "ModifiedEntity"; and "date_application", which can optionally contain one "Date". Constraint on "Modification" requires that a "Modification" must contain at least one "modifications".

- "ModifiedEntity" specifies the constraint that each "ModifiedEntity" must contain at least one "modified_entity".

- "Date" specifies the constraint that each "Date" must contain at least one "date_application".

There are two predicates defining counter examples: "CtrEx1" and "CtrEx2".
 
- "CtrEx1" asserts that there are no modifications.

- "CtrEx2" asserts that there exists a modification for which there is neither a modified entity nor a date of application.

A predicate named "ModificationSpec" takes in a "Modification" and asserts that it contains exactly one "modified_entity" and one "date_application".

Another predicate, "Specification", firstly requires the presence of at least one modification, and secondly asserts that for all modifications in "Avenant" the conditions set out in "ModificationSpec" hold.

There is an assertion named "la_specification_respecte_les_contre_exemples", which asserts that the model counters the counterexamples represented by "CtrEx1" and "CtrEx2". 

Finally, a check command checks the above assertion for 3 scopes but only allows 1 "Avenant". A run command executes the "Specification" predicate to demonstrate its functionality with a scope of 3 for general case but restricts "Avenant" to only 1 instance, and requires exactly 2 "Modification".
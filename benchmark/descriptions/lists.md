This Alloy model is a representation of a simple list module demonstrating the creation of predicates and fields to permit recursive constraints. 

This model contains a signature Thing, however, all elements of type Thing are necessarily contained in List.car, which means there are no stray Things.

There are three types of List: abstract signature List, NonEmptyList, and EmptyList. Every List has two sets associate with it, "equivTo" and "prefixes". For a NonEmptyList, it has also 'car' that is a singular type Thing and 'cdr' that is a singular type List. An EmptyList doesn't have either of these attributes.

The predicate isFinite asserts the finitude of a given List by its termination. It returns whether the given list 'L' contains an EmptyList as part of its recursive instances of 'cdr'.

The model guarantees that every 'List' object obeys the isFinite predicate with a fact named finite.

The model defines an Equivalence fact stating that for any given two lists 'a' and 'b', ‘a’ is equivalent to 'b' if and only if 'a.car' equals 'b.car' and the rest of the list 'b.cdr' is equivalent to 'a' and the total number of recursive 'cdr' of 'a' and 'b' are equal.

The model verifies the reflexive property of equivalence relation in the assert called reflexive, ensuring a list is equivalent to itself.

The model checks the symmetric property of equivalence relation in the assert called symmetric. That is, if list 'a' is equivalent to list 'b' then list 'b' is equivalent to list 'a'

Similarly, the model checks if all empty lists are equivalent to each other in the assert called empties.


As for the prefix, a fact is defined as follows: empty list 'e' is a prefix of any list, and a non-empty list 'a' is a prefix of a list 'b' if and only if their 'car' properties are equal, the rest of the list 'a.cdr' is a prefix of 'b.cdr', and the total number of recursive 'cdr' in list 'a' is less than that in list 'b'.

Additionally, it contains a predicate show, that checks for the existence of two different non-empty lists 'a' and 'b' where 'b' is a prefix of 'a'.

The model finally runs the predicate show for a multiplicity of 4. It is expected that one such instance will be found.
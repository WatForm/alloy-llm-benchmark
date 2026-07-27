There are disjoint sets called "Object" and "Name".

Every "File" and every "Dir" is in "Object", and every "Object" is either a "File" or a "Dir" (not both). 

There is a set called "Name".

There is a set called "DirEntry". Each "DirEntry" has:
- a "name" relation to exactly one "Name",
- a "contents" relation to exactly one "Object".

Each "Dir" has:
- an "entries" relation to a set of "DirEntry" elements,
- a "parent" relation to at most one "Dir".

Every "File" is the "contents" of at least one "DirEntry" that belongs to the "entries" of some "Dir".

Every "Dir"'s' "parent" is exactly the unique "Dir" whose "entries" contains a "DirEntry" whose "contents" is that "Dir". 

There are no duplicate "Name"s within one "Dir"'s "entries".

The "parent" relation contains no cycles.

Every "Dir" that is not the "Root" can reach the "Root" in one or more steps of the "parent" relation.

There is exactly one "Root", and "Root" is a "Dir". "Root" has no "parent".

There is at most one "Cur", which is not the "Root", and "Cur" is a "Dir".

Every "DirEntry" belongs to the "entries" of exactly one "Dir".

Every "Dir" other than "Root" has exactly one "parent" and is the "contents" of exactly one "DirEntry".


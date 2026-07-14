There is a set called "Object".

The sets "Directory" and "File" are non-overlapping subsets of "Object".
Every element of "Object" is in at least one of these sets.

"Alias" is a subset of "File".

There is one distinguished single element named "Root", which is a Directory.

Each "Directory" is related by "contents" to a set of "Object" elements.

Each "Alias" is related by "to" to exactly one "Object".

The "Root" is not in the "contents" of any "Directory".

The "Root" can reach every Object except itself through iterating the "contents" relation.

"contents" is acyclic.

Every "Object" is in the "contents" of at most one "Directory".

"to" is acyclic.

There is a two disjoint sets called "Target" and "Book".

All "Addr"s are "Target"s.
All "Name"s are "Target"s.

The sets "Addr" and "Name" are disjoint and together they contain all elements of "Target".
There are two sets, "Alias" and "Group" that partition "Name".

There is a set called "Book".  
Each "Book" has a mapping from a "Name" to a "Target", called its "addr".

For every book, there is no element of "Name" that can reach itself by following one or more steps of the "addr" relation of the book.

For every element of "Book" and every element of "Alias", the "Alias" maps directly to at most one "Target" via a single step of the "addr" relation of that "Book".

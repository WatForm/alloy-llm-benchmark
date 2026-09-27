There are two disjoint sets called "Listing" and "Book".

Every "Address" is a "Listing", and every "Name" is a "Listing". 
Every element of "Listing" belongs to either "Address" or "Name", but not both.

There is a set called "Book". 
A "Book" has an "entry", which is a set of "Name" elements. 
A "Book" has "listed" information, which is a mapping between its "entry" and a set of "Listing"s.

The result of looking up a book and a name is the set of all "Listing" elements reachable from that name by following the "listed" relation starting with that book, one or more times.

For every "Book" and every "Name" in the book's "entry", there is at most one "Listing" in the book's "listed" information for that "Name".

If a "Name" is in the resulting from looking up a book and a name, then that name is in that book's "entry".

All names in a book's entry cannot be in the set resulting from looking up that book and the name.

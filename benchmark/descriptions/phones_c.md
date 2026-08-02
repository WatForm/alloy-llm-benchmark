There is a set of elements named "Phone".

Each "Phone" is related to a set of "Phone", called its "requests".
Each "Phone" "connects" to at most one "Phone".
Each "Phone" "forward"s to at most one "Phone".

All "connects" pairs are in the set of pairs where the first "Phone" of the pair is the source of a "requests" and when the second "Phone" 
can be reached from the "Phone" that is the destination of the "requests" by following zero or more "forward" links, ending with a "Phone" that is not "forward"ed to any phone.
 
No phone can be the target of "connects" from more than one "Phone".

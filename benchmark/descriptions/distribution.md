This Alloy model specifies a property over a set and two relations in a univeral set. It defines an assertion named 'union'.

The set, denoted by 's', belongs to the universal set 'univ'. 

Then, two relations 'p' and 'q' are also defined within the universal set 'univ'. Both 'p' and 'q' are binary relations, mapping elements from 'univ' to 'univ'. 

The assertion 'union' states that, for every set 's' in the universal set and every pair of relations 'p' and 'q' in the universal set, applying 'p' and 'q' to 's' simultaneously (notated as 's.(p+q)') yields the same result as applying 'p' to 's' and then applying 'q' to 's' (notated as 's.p + s.q').

Finally, this Alloy model includes a check command which checks the assertion 'union' for a scope of 4. This implies that the assertion is checked assuming the maximum size for the universal set is 4.
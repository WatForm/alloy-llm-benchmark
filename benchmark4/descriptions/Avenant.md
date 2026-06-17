There are four disjoint sets called "Amendment", "Modification", "ModifiedEntry", and "Date".

There is exactly one "Amendment".  It is linked to a set of "Modifications" in a relation called "modifications".

Every "Modification" is related to at most one "ModifiedEntry" through the pairs is "modified_entity".  Every modification has at most one "application_date".

Every "Modification" is in the set of "modifications" of some "Amendment".

Every "ModifiedEntry" is in the set of "modified_entities" of some "Modification".

Every "Date" is in the set of "application_date"s of some "Modification".

There are some "modifications". Every "Modification" associated with an "Amendment" has exactly one "modified_entry" and exactly one "application_date".

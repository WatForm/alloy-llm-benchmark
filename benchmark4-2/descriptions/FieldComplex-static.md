There are disjoint sets named "Field", "Game", and "Date".

Each element of "Game" has exactly one "where" value, and that value is an element of "Field". Each element of "Game" also has exactly one "when" value, and that value is an element of "Date".

There is exactly one element named "FieldComplex". "FieldComplex" has a relation named "schedule" that matches "FieldComplex"es with "Games", and any number of games may be in the relation with the same "FieldComplex".

There is some "Game" that is in the "schedule" of "FieldComplex" or has no "where" value and no "when" value.

There is some element of "Game" that is not in the "schedule" of "FieldComplex" or it has exactly one "where" value and exactly one "when" value.

For any two distinct elements of "Game", if they have the same "where" value, then they have different "when" values.

There exists at least one element of "Game" that is not in the "schedule of "FieldComplex".


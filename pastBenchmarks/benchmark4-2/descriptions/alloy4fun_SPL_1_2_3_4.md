There are four disjoint kinds of elements: "StoredModel", "Link", "Command", and "Instance".

The "derivationOf" a "StoredModel" is one or no "StoredModel".
Each "StoredModel" is associated with one or no "public" "Link".
Each "StoredModel" is associated with one or no "secret" "Link".
Each "StoredModel" is associated with one or no "Command", called its "command".

"Secret" is a subset of "StoredModel".

Each "Instance" is associated with exactly one "instanceOf" value, which is a "Command".
Each "Instance" is associated with a set of "StoredModel"s, called its "model".
Each "Instance" is associated with exactly one "Link", called its "link".


Every "Link" is exactly one of 1) the "public" value of some "StoredModel", 2) the "secret" value of some "StoredModel", or 3) the "link" of some "Instance".

Every "StoredModel" that has a "secret" "Link" is a "Secret".

Every "Secret" that has a "secret" "Link" must have a "public" "Link".

Every "Secret" that has a "public" "Link" must reach a "secret" "Link" or must be reach a "secret" "Link" via one or more "derivationOf" steps.

No "StoredModel" is reachable from itself by following "derivationOf" one or more times.

Every "StoredModel" that has no "public" "Link" is the "derivationOf" at most one "StoredModel".

Every "StoredModel" that can be reached by one or more steps of the "derivationOf" of a "Secret" is also a "Secret".

If a "Secret" has a "public" value and no "secret" value, then there is no "StoredModel" that can reach it by following "derivationOf" zero or more times that has a "secret" value.

Every "Command" is the "command" of exactly one "StoredModel".

Every "StoredModel" has no "public" value if and only if it has some "command".

For every "Instance", its "model" set is exactly the set of "StoredModel"s whose "command" value is the "instanceOf" value of the "Instance".

Every "Command" has at most one "Instance" that is the "instanceOf" of that "Command".

would be TRUE for disconnected components!
    That would mean disconnected components have 0 roots, which is $\le 1$, so it would ALLOW disconnected components!
    That would NOT enforce that there is at most one root!
    Therefore, a root MUST be defined as a node having no parent:
    `no c.genls` (or `no (~genls).c`)!
    And "at most one root" means:
    `lone c: C | no c.genls`!
    Wait, what if someone defines "root" as `no c.genls`, let's check:
    If $A$ and $B$ are disconnected, both have `no genls`.
    How many nodes have `no genls`? Two!
    Is 2 `lone`? No!
    So `lone c: C | no c.genls` rejects disconnected components!
    Every node in $C$ must trace back to the UNIQUE root (if $C$ is non-empty).
    This is precisely what "at most one root" means in English and graph theory!

8.  **Let's check the DAG condition in Alloy:**
    "The inverse of "genls" forms a directed acyclic graph"
    In Alloy, how is a DAG written?
    Option A: `no iden & ^genls`
    Option B: `all c: C | c not in c.^genls`
    Option C: `no c: C | c in c.^genls`
    Option D: `all c: C | c not in c.^(~genls)`
    Option E: `no iden & ^(~genls)`
    Wait! Are `no iden & ^genls` and `no iden & ^(~genls)` completely identical?
    Yes, because $c \in c.\text{^genls} \iff c \in c.\text{^(~genls)}$.
    Transitive closure of inverse is inverse of transitive closure:
    $(\sim R)^+ = \sim (R^+)$.
    And $(c, c) \in R^+ \iff (c, c) \in \sim (R^+)$.
    So `no iden & ^genls` $\equiv$ `no iden & ^(~genls)`.
    Wait, is `all c: C | c not in c.^genls` more readable / common?
    Let's check common Alloy styles:
    Both `no iden & ^genls` and `all c: C | c not in c.^genls` (or `no c: C | c in c.^genls`) are very common.
    Wait, what about writing:
    `all c: C | c not in c.^genls`
    Wait, what if we write `no c: C | c in c.^genls`?
    Wait, what if we write:
    ```alloy
    all c: C |
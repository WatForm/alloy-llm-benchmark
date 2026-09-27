at most one root (`lone c: C | no c.genls`), there will be EXACTLY one root if $C$ is non-empty, and 0 roots if $C$ is empty!
    Which matches "at most one root" perfectly.

    Description chunk 4:
    "Each element of "E" is related by "isas" to one or more elements of "C", meaning the element of "E" is a "C"."
    -> In `E`: `isas: some C`.

    Description chunk 5:
    "Each element of "E" is also related by "all_isas_attr" to zero or more elements of "C"."
    -> In `E`: `all_isas_attr: set C`.

    Description chunk 6:
    "The set of "C"s that related to an individual "E" using "all_isas_attr" is equal to the set of "C"s resulting from the "C"s that can be reached in zero or more steps of "genls" starting from the "C"s that are connected to the "E" via "isas".
    Because zero "genls" steps are allowed, this includes the "C"s directly related "isas" elements themselves."
    -> `all e: E | e.all_isas_attr = e.isas.*genls`

    Description chunk 7:
    "For every element of "E", there is no element of its "isas" set that is reachable by zero or more "genls" steps from another distinct element of its "isas" set."
    -> `all e: E | no disj c1, c2: e.isas | c1 in c2.*genls`
    Wait, could it be written:
    `all e: E | all c: e.isas | no (e.isas - c) & c.*genls`?
    Wait, let's trace:
    "there is no element of its 'isas' set [$c_1$] that is reachable by zero or more 'genls' steps from another distinct element of its 'isas' set [$c_2$]"
    If $c_1$ is reachable from $c_2$:
    $c_2 \to^* c_1$, which means $c_1 \in c_2.*genls$.
    If we write:
    `all e: E | no disj c1, c2: e.isas | c1 in c2.*genls`
    Let's test this:
    Suppose $e.isas = \{ Dog, Mammal \}$.
    $Dog \neq Mammal$.
    Is $Mammal \in Dog.*genls$? Yes, $Dog \to Mammal$ via $genls$.
    So $c_1 = Mammal, c_2 = Dog$.
    $c_1 \in c_2.*genls$ is true.
    Thus `no disj
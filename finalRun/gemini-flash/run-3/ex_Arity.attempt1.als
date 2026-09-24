` mean `all b: B | one a.r[b]` or does it mean `one (a.r)`?
    LET'S CHECK THIS VERY CAREFULLY!
    THIS IS A CRITICAL DETAIL IN ALLOY!
    What does `A -> one B` mean?
    In Alloy:
    `p: A -> one B` means for every $a \in A$, there is exactly one $b \in B$ such that $a.p = b$.
    Now, in `sig A { r: B -> one C }`:
    Here `r` is declared inside `sig A`.
    In Alloy, the declaration of a field `f: expr` inside `sig A` means:
    The type of `f` is `A -> expr`.
    And for each `this: A`, `this.f` satisfies the constraints of `expr`!
    What is `expr` here? `expr` is `B -> one C`.
    What does the expression `B -> one C` mean?
    It is an arrow product of `B` and `C`, with the multiplicity `one` on `C`.
    So for any relation $R$ constrained by `B -> one C`,
    every element of $B$ is mapped to exactly one element of $C$!
    Wait, let's verify: does `B -> one C` mean every $b \in B$ is mapped to exactly one $c \in C$?
    YES! In Jackson's book, Section 4.4.3:
    "An arrow product with a multiplicity marker, such as `A -> mult B`, represents a relation whose tuples are drawn from the Cartesian product of `A` and `B`, and which satisfies the constraint that each element of `A` is mapped to `mult` elements of `B`."
    Therefore, `B -> one C` represents a relation from `B` to `C` where each element of `B` is mapped to `one` element of `C`.
    And inside `sig A`:
    Each atom `a` of `A` has `a.r` drawn from `B -> one C`.
    Thus, for each `a \in A`, `a.r` is a total function from `B` to `C`!

20. **Wait! What if the user declared `r` as: `r: B -> one C` vs `r: B -> C`?**
    Wait, what if someone wrote:
    ```alloy
    sig A {
        r: B -> one C
    }
    ```
    Is there any other interpretation of:
    "Each element of 'A' is associated by 'r' with a relation from 'B' to 'C'.
    'r' is a total function."

    Wait, could `r` be:
    "r is a total function"
    Could it mean `r` is a total function from
would someone write `p.~connects`?
    Because in Alloy, people often think of `p.field` as "dereferencing" the field `connects` from `p`.
    So `p.connects` is the phone `p` connects to.
    And `p.~connects` is the phone that connects to `p`.
    Wait, what if someone wrote `connects.p`?
    Let's check:
    In Alloy, `connects.p` is also completely standard.
    Wait, is there any difference in semantics between `all p: Phone | lone connects.p` and `all p: Phone | lone p.~connects`?
    None. They produce the EXACT same AST / relational semantics in the Alloy analyzer.
    Wait, does `connects.p` parse without error?
    Yes! Let's trace Alloy's parser:
    `connects` is an identifier (expr).
    `.` is an operator.
    `p` is an identifier (expr).
    `connects.p` is `ExprDot(connects, p)`.
    `lone connects.p` is `ExprUnary(LONE, ExprDot(connects, p))`.
    It is 100% valid syntax.

9.  **Wait! Let's check the first constraint again:**
    "All "connects" pairs are in the set of pairs where the first "Phone" of the pair is the source of a "requests" and when the second "Phone" can be reached from the "Phone" that is the destination of the "requests" by following zero or more "forward" links, ending with a "Phone" that is not "forward"ed to any phone."

    Could this constraint be:
    `connects in requests.*forward :> {p: Phone | no p.forward}`
    Wait, let's re-read:
    "All "connects" pairs are in the set of pairs where the first "Phone" of the pair is the source of a "requests" and when the second "Phone" can be reached from the "Phone" that is the destination of the "requests" by following zero or more "forward" links, ending with a "Phone" that is not "forward"ed to any phone."

    Wait, is `{p: Phone | no p.forward}` or `Phone - forward.Phone` or `{p: Phone | no p.forward}`?
    Wait, what if it was:
    ```alloy
    fact {
        all p: Phone | p.connects in p.requests.*forward and no p.connects.forward
    }
    ```
    Wait! Look at the sentence structure again:
    "All "connects" pairs are in the set of pairs where the first "Phone" of the pair is the source of a "requests" and when the second "Phone" can be reached from the "Phone" that is the destination of
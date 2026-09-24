left.right) = (j.left, j) in right`.
    So `(j, j) in left.right in (left + right).(left + right)`.
    This is a cycle of length 2: `j -> j.left -> j`.
    If `no iden & ^(left + right)`, then no such cycle can exist.
    Therefore, NO JOINTS can exist!
    And for Ends:
    `e = e.right.left` -> `(e, e.right) in right` and `(e.right, e) in left`.
    Cycle of length 2: `e -> e.right -> e`.
    Therefore, NO ENDS can exist!
    Since `Vertex = Joint + End`, NO VERTICES can exist!
    The only model would be `Vertex = none`.
    Therefore, NO ONE could have written `v not in v.^(left + right)`.
    That is 100% ruled out.

    Wait! What about `v not in v.^left` and `v not in v.^right`?
    Can `v in v.^left` happen in a line?
    If it's a line, no, `left` has no cycles, and `right` has no cycles.
    And `Vertex - v = v.^left + v.^right` already guarantees that:
    - `left` and `right` have no cycles (since `v not in v.^left` and `v not in v.^right`).
    - Every vertex is connected in this line.
    - There are no branches (combined with lone left/right).

5.  **Let's check the structure of the model**:
    Signatures:
    ```alloy
    abstract sig Vertex {
        left: lone Vertex,
        right: lone Vertex
    }

    sig Joint extends Vertex {}
    sig End extends Vertex {}
    ```
    Wait, could `sig Joint, End extends Vertex {}` be preferred over two separate declarations?
    Both are completely equivalent in Alloy syntax and semantics.
    Let's check the prompt:
    "There are two non-overlapping subsets of "Vertex", named "Joint" and "End". Every vertex is a Joint or an End."
    `sig Joint, End extends Vertex {}` or
    `sig Joint extends Vertex {}`
    `sig End extends Vertex {}`
    In Alloy, writing `sig Joint, End extends Vertex {}` declares two signatures, `Joint` and `End`.
    Writing them separately:
    ```alloy
    sig Joint extends Vertex {}
    sig End extends Vertex {}
    ```
    is also very clear and standard.

    Wait! What about the facts?
    Can we write them in a single `fact` block?
    ```alloy
    fact {
        all e: End {
            (no e.left and e = e.right.left) or
            (no e.right
vertex CANNOT satisfy the End condition!
    Thus, a valid model must have at least 2 vertices (e.g. 2 Ends).
    This is completely consistent with the English description.

    Wait, what about `e = e.right.left` vs `e.right.left = e`?
    They are identical in Alloy.
    Let's check the English:
    "the "End" is equal to the "left" value of its "right" value"
    "the End" -> `e`
    "is equal to" -> `=`
    "the "left" value of its "right" value" -> `e.right.left`.
    Writing `e = e.right.left` directly mirrors "the End is equal to the left value of its right value"!
    And `e = e.left.right` directly mirrors "the End is equal to the right value of its left value"!

    Let's check Joint:
    "For every "Joint":
    - following "left" and then "right" returns to that same element, and
    - following "right" and then "left" returns to that same element, and
    - its "left" value and its "right" value are different."
    - "following "left" and then "right" returns to that same element":
      `j.left.right = j`
    - "following "right" and then "left" returns to that same element":
      `j.right.left = j`
    - "its "left" value and its "right" value are different":
      `j.left != j.right`
    This matches word-for-word!

    Let's check Vertex:
    "For every element of "Vertex", the other elements of "Vertex" are exactly those reachable from it either by a nonempty path of only repeated "left" steps or by a nonempty path of only repeated "right" steps; an element is not reachable from itself."
    - "For every element of Vertex" -> `all v: Vertex`
    - "the other elements of Vertex" -> `Vertex - v`
    - "are exactly those" -> `=`
    - "reachable from it either by a nonempty path of only repeated "left" steps or by a nonempty path of only repeated "right" steps" -> `v.^left + v.^right`
    - "; an element is not reachable from itself." -> `v not in v.^left + v.^right` (or `v not in v.^left and v not in v.^right`).

    Wait! Is there any reason to prefer:
    `v not in v.^left + v.^right`
    over
    `v not in v.^left and v not in v.^right`?
    `v not in v.^left + v.^right` is very elegant and concise.
    Wait, could it also be written as:
    ```alloy
    all
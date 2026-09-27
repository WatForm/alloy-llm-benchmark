mentioned in quotes:
    Signatures:
    - "Object"
    - "Directory"
    - "File"
    - "Alias"
    - "Root"
    Relations:
    - "contents"
    - "to"

    Let's check if our signatures and relations match EXACTLY this list:
    Signatures:
    - `Object`
    - `Directory`
    - `File`
    - `Alias`
    - `Root`
    Relations:
    - `contents`
    - `to`
    Exact match! 5 signatures, 2 relations.

13. **Let's examine: `Alias extends File` vs `Alias in File`:**
    Wait, if `Alias in File`, is `Alias` a signature?
    Yes, in Alloy, `sig Alias in File` is a subset signature.
    Wait, if `Root extends Directory`, is `Root` a signature?
    Yes, `one sig Root extends Directory {}`.
    Wait, why would someone use `extends` for `Root` and `extends` for `Alias`?
    Let's check:
    If `sig Alias extends File {}`:
    Can there be Files that are not Aliases?
    YES! Because `File` is NOT declared abstract!
    In Alloy:
    ```alloy
    sig File extends Object {}
    sig Alias extends File {
        to: one Object
    }
    ```
    Let's confirm this behavior in Alloy:
    If you have:
    ```alloy
    sig A {}
    sig B extends A {}
    run { some A - B }
    ```
    Is `some A - B` satisfiable in Alloy?
    YES! In Alloy, extending a non-abstract signature allows elements in the parent that are not in the child.
    Now, what if `sig Alias in File`?
    ```alloy
    sig File extends Object {}
    sig Alias in File {
        to: one Object
    }
    ```
    Is `some A - B` satisfiable in Alloy?
    YES!
    So what is the difference between `sig Alias in File` and `sig Alias extends File`?
    In Alloy:
    - `extends` establishes single inheritance with disjoint subsignatures.
    - `in` establishes subset signatures.
    Wait! What did the prompt say?
    `"Alias" is a subset of "File".`
    Why did it use the word "subset"?
    Wait, look at how the prompt introduced Directory and File:
    `The sets "Directory" and "File" are non-overlapping subsets of "Object".`
    `Every element of "Object" is in at least one of these sets.`
    Here, it used "subsets" too!
    "Directory and File are non-overlapping subsets of Object" -> they both extend Object!
    So the author uses the word "subset" to describe `extends`!
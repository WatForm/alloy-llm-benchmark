"
    `Dir.entries` IS the set of all DirEntries that belong to the entries of some Dir!
    So `some e: Dir.entries | e.contents = f` says:
    There is some DirEntry `e` in `Dir.entries` (meaning it belongs to the entries of some Dir) such that `e.contents = f`.
    Wait, does `some d: Dir | some e: d.entries | e.contents = f` say the exact same thing?
    Yes, `some e: Dir.entries | e.contents = f` <=> `some d: Dir | some e: d.entries | e.contents = f`.
    Let's write:
    `all f: File | some d: Dir | some e: d.entries | e.contents = f`
    Wait, is there any ambiguity? None.

20. **Let's check the structure of the file**:
    Can facts be in a single `fact` block or separate facts?
    In Alloy, having a single `fact` block or separate facts:
    Wait, could we name the facts or just put them in an anonymous `fact` block?
    An anonymous `fact { ... }` block is standard and avoids introducing any extra identifiers (remember: "Any text enclosed in double quotes in the description dictates the exact identifier you must use... Use exactly this set of signatures and relations in the model").
    If we used a named fact like `fact ParentRules { ... }`, `ParentRules` would be an extra identifier!
    So anonymous `fact { ... }` is much safer and cleaner.

    Wait! Can some constraints be put inside the signatures?
    Let's check:
    Sentence 4:
    "There is a set called "DirEntry". Each "DirEntry" has:
    - a "name" relation to exactly one "Name",
    - a "contents" relation to exactly one "Object"."
    ```alloy
    sig DirEntry {
        name: one Name,
        contents: one Object
    }
    ```

    Sentence 5:
    "Each "Dir" has:
    - an "entries" relation to a set of "DirEntry" elements,
    - a "parent" relation to at most one "Dir"."
    ```alloy
    sig Dir extends Object {
        entries: set DirEntry,
        parent: lone Dir
    }
    ```

    Wait! What about:
    Sentence 2:
    "Every "File" and every "Dir" is in "Object", and every "Object" is either a "File" or a "Dir" (not both)."
    ```alloy
    abstract sig Object {}

    sig File extends Object {}

    sig Dir extends Object {
        entries: set DirEntry,
        parent: lone Dir
    }
    ```
    Is `Object` abstract?
    "every Object is either a File or a Dir (not both)"
    If
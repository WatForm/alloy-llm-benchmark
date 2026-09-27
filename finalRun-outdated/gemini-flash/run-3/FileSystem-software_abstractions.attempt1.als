contain any elements outside `Object`?
    No, `Object` is the top-level signature, all atoms are `Object`s.
    So `Root.^contents` is a subset of `Object - Root`.
    If Option A holds, `Object - Root` is a subset of `Root.^contents`.
    Therefore, `Root.^contents = Object - Root`.
    So Option A and Option B are provably equivalent under the acyclic constraint!
    Wait, what if acyclic wasn't there?
    Option B explicitly says `Root` cannot reach itself (since `Root !in Object - Root`).
    Wait, what does the English say?
    "The "Root" can reach every Object except itself through iterating the "contents" relation."
    Notice: "can reach every Object except itself"
    Does it say "and cannot reach itself"?
    Well, if someone says: "The Root can reach every Object except itself",
    in English, this specifies what Root can reach: namely, `Object - Root`.
    Writing `Root.^contents = Object - Root` is both beautiful, concise, and standard in Alloy.
    Wait, what if someone wrote:
    `all o: Object - Root | o in Root.^contents`?
    Wait, what if we check Jackson's book for the exact formula?
    In Jackson's *Software Abstractions*, page 43:
    Let's check the exact code for reachable objects from root:
    Wait, in Chapter 3:
    ```alloy
    sig Directory extends Object { contents: set Object }
    ```
    Is it:
    `Root.^contents = Object - Root`?
    Wait, on page 43, Jackson writes:
    "all objects reachable from root"
    ```alloy
    fact Reachable {
        Root.^contents = Object - Root
    }
    ```
    Wait, does he write `Root.^contents = Object - Root` or `Object in Root.*contents`?
    Wait! In Jackson's book:
    `Root.*contents = Object`
    Wait!
    Does `Root.*contents = Object` mean Root can reach every Object including itself?
    Yes! BUT the prompt says:
    "The "Root" can reach every Object except itself through iterating the "contents" relation."
    Why did the author write "iterating the contents relation" and "except itself"?
    Because `^` is the transitive closure (iterating one or more times), whereas `*` is reflexive transitive closure (zero or more times)!
    In Alloy:
    `^contents` is the iteration / transitive closure of `contents`.
    With `^contents`, Root can reach `Root.^contents`.
    Root reaches itself through 0 steps (`*contents`), but through iterating (`^contents`), it reaches `Object - Root`!
    And "except itself" means `Object - Root`!
    So `Root.^contents = Object - Root
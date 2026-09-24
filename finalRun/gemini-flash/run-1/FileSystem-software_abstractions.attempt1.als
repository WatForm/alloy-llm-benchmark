no parent"
    `no contents.Root` (or `no d: Dir | Root in d.contents`)

    Fact 2: "All objects reachable from the root" / "every file system object is reachable from the root"
    In Jackson:
    `FSObject in Root.*contents` (or `Root.*contents = FSObject`)
    Wait! But look at our English description:
    "The "Root" can reach every Object except itself through iterating the "contents" relation."
    Notice why our description says:
    "The "Root" can reach every Object except itself through iterating the "contents" relation."
    Because `Root.^contents = Object - Root`!
    Or `Object - Root in Root.^contents`!
    Wait, if `Root.*contents = Object`, does `Root.^contents = Object - Root`?
    Let's check:
    Since `contents` is acyclic, `Root not in Root.^contents`.
    `Root.*contents = Root + Root.^contents`.
    If `Root.*contents = Object`, then `Root + Root.^contents = Object`.
    Subtracting `Root` from both sides:
    `Root.^contents = Object - Root`.
    They are 100% mathematically equivalent when contents is acyclic!
    Wait, what if we write:
    `Root.^contents = Object - Root`?
    That directly translates the words:
    - "The Root": `Root`
    - "can reach ... through iterating the contents relation": `.^contents`
    - "every Object except itself": `Object - Root`
    - `=`: `Root.^contents = Object - Root`!
    Wait, could it be:
    `all o: Object - Root | o in Root.^contents`?
    Notice that `Root.^contents = Object - Root` is also:
    `Object - Root in Root.^contents` AND `Root not in Root.^contents`.
    Both are completely valid. But `Root.^contents = Object - Root` is very concise and unambiguous.
    Wait, what if there are no other objects? (i.e. Object = Root).
    Then `Object - Root = none`.
    `Root.^contents = none`.
    It works!

    Fact 3: ""contents" is acyclic."
    How is this written?
    `no iden & ^contents`
    Wait, what if someone wrote `all d: Directory | d not in d.^contents`?
    Let's check:
    If `no iden & ^contents`:
    Can any `File` be in a cycle?
    A `File` has no `contents` field (only `Directory` has `contents: set Object`).
    So `File.contents` doesn't exist, meaning no tuple in `contents` has a File in the first position.
    So only `Directory` could ever be in a cycle of `contents`.
    Therefore:
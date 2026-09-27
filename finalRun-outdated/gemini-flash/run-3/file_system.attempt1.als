`d.parent` as the unique Dir whose entries contains a DirEntry whose contents is `d`,
    then `d.parent = { p: Dir | some e: p.entries | e.contents = d }`.
    Wait, is Option 1 and Option 2 identical in Alloy?
    In Alloy:
    `d.parent = { p: Dir | some e: p.entries | e.contents = d }`
    means the set `d.parent` equals the set `{ p: Dir | ... }`.
    `p in d.parent iff (some e: p.entries | e.contents = d)`
    means for all `p: Dir`, `p in d.parent` iff `some e: p.entries | e.contents = d`.
    By set extensionality, since both `d.parent` and `{ p: Dir | ... }` are sets of `Dir`,
    `d.parent = { p: Dir | some e: p.entries | e.contents = d }` and `all p: Dir | p in d.parent iff (some e: p.entries | e.contents = d)` are completely identical!
    Wait, which one is more standard in Alloy?
    `all d: Dir, p: Dir | p in d.parent iff (some e: p.entries | e.contents = d)`
    Wait, or:
    `all d: Dir | all p: Dir | p = d.parent <=> (some e: p.entries | e.contents = d)`?
    Wait! If `d.parent` has at most one element (`lone Dir`), then `p in d.parent` is equivalent to `p = d.parent` when `p` is in `d.parent`.
    Wait, what if `d.parent` is empty?
    If `p = d.parent`, in Alloy:
    If `d.parent` is empty (none) and `p` is an atom, `p = d.parent` evaluates to `false`.
    If the right hand side is false, `false <=> false` is true.
    BUT in Alloy, comparing a scalar to an empty set with `=` might be fine, but `p in d.parent` is much more standard and idiomatic relational logic!
    Wait, what about:
    `all d: Dir | d.parent = { p: Dir | some e: p.entries | e.contents = d }`?
    Look at the English:
    "Every 'Dir''s 'parent' is exactly the unique 'Dir' whose 'entries' contains a 'DirEntry' whose 'contents' is that 'Dir'."
    "Every Dir's parent" -> `d.parent`
    "is exactly" -> `=`
    "the unique Dir whose entries contains a DirEntry whose contents is that Dir" -> `{ p: Dir | some e: p.entries | e.contents = d }`
    Look at how direct that
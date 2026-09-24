p in Client.loaned)`
    `no (Museum.onDisplay & Client.loaned)`
    Does `all p: Picture | p in Museum.onDisplay or p in Client.loaned` imply `Picture in Museum.onDisplay + Client.loaned`?
    Yes, because for every `p: Picture`, `p in Museum.onDisplay + Client.loaned`.
    And since `Museum.onDisplay + Client.loaned in Picture` (by signature typing), `Picture = Museum.onDisplay + Client.loaned`.

    Wait, what about `either ... or` again?
    Could "Every "Picture" is either in "onDisplay" in the Museum" or "loaned" to a "Client"." be:
    `all p: Picture | (p in Museum.onDisplay) or (p in Client.loaned)`?
    Wait, what if someone wrote `xor`?
    `all p: Picture | (p in Museum.onDisplay) xor (p in Client.loaned)`
    Let's look at the words:
    "Every "Picture" is either in "onDisplay" in the Museum" or "loaned" to a "Client"."
    If someone wrote `xor`, what happens to:
    "No "Picture" is both in "onDisplay" on a "Museum" and "loaned" to any "Client"."
    That would be:
    `no (Museum.onDisplay & Client.loaned)`
    Wait! If we write:
    ```alloy
    all p: Picture | (p in Museum.onDisplay) or (p in Client.loaned)
    no (Museum.onDisplay & Client.loaned)
    ```
    Could anyone possibly object?
    Sentence 1: "Every Picture is either in onDisplay in the Museum or loaned to a Client" -> `all p: Picture | (p in Museum.onDisplay) or (p in Client.loaned)` (or `xor`)
    Wait, what if we write `xor`?
    If we write:
    `all p: Picture | (p in Museum.onDisplay) xor (p in Client.loaned)`
    and
    `no (Museum.onDisplay & Client.loaned)`
    Is having both completely fine? Yes!
    Wait, why not just write:
    `all p: Picture | (p in Museum.onDisplay) or (p in Client.loaned)`?
    Wait, in English, "either A or B" strictly speaking in English grammar is often used with "or": "either ... or ...".
    "either ... or" in English grammar is a correlative conjunction!
    The correlative conjunction is "either ... or ...".
    In standard English, "either ... or ..." does NOT inherently mean exclusive OR; it is often just the paired form of "or" (e.g. "You can either call me or send an email").
    Because
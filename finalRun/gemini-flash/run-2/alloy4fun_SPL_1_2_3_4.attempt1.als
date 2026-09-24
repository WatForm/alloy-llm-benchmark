` join: `(*R).s` joins `(m, s)` with `s` -> gives `m`!
      So `(*derivationOf).s = { m: StoredModel | s in m.*derivationOf }`.
      And "that has a secret value":
      Those `m` that have a secret value: `m.secret != none` (i.e. `m in secret.Link`).
      "there is no StoredModel ...":
      `no ((*derivationOf).s & secret.Link)` or `no m: StoredModel | s in m.*derivationOf and some m.secret`.
      Wait, `no m: StoredModel | s in m.*derivationOf and some m.secret` is SO clear, nobody can misunderstand it!
      Wait, let's re-read the English of Fact 8 again:
      "If a "Secret" has a "public" value and no "secret" value, then there is no "StoredModel" that can reach it by following "derivationOf" zero or more times that has a "secret" value."
      Wait! Could "there is no StoredModel that can reach it" mean:
      Could "it" be the one reaching?
      No: "there is no StoredModel that can reach it"
      "StoredModel" is the subject, "can reach" is the verb, "it" is the object.
      "that has a secret value" is a relative clause modifying "StoredModel".
      So: No StoredModel m (such that m has a secret value) can reach it (s).
      Wait, why zero or more times?
      If it were 0 times, m = s. Does s have a secret value? No, the premise says "and no secret value".
      If it were 1 or more times, m reaches s in 1+ steps.
      Wait, earlier we asked: why does Fact 8 say this?
      Let's check the Alloy4Fun logic!
      In Alloy4Fun:
      You have a Secret model `s`.
      Suppose you generate a public link for it, but NOT a secret link.
      Wait, why would a Secret have a public link and no secret link?
      Wait, look at Fact 3:
      "Every "Secret" that has a "secret" "Link" must have a "public" "Link"."
      Does Fact 3 say every Secret that has a public link must have a secret link?
      NO! It says: if it has a secret link, it must have a public link!
      So a Secret CAN have a public link and NO secret link!
      Now look at Fact 4:
      "Every "Secret" that has a "public" "Link" must reach a "secret" "Link" or must be reach a "secret" "Link" via one or more "derivationOf" steps."
      WAIT! Look at Fact
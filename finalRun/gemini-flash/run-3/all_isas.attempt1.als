: wait, in Alloy, `no disj c1, c2: e.isas | c1 in c2.*genls` is very clean and standard!

Wait! Let's check `all_isas_attr`:
"Each element of "E" is also related by "all_isas_attr" to zero or more elements of "C"."
"The set of "C"s that related to an individual "E" using "all_isas_attr" is equal to the set of "C"s resulting from the "C"s that can be reached in zero or more steps of "genls" starting from the "C"s that are connected to the "E" via "isas"."
"Because zero "genls" steps are allowed, this includes the "C"s directly related "isas" elements themselves."

How is this expressed in Alloy?
`all e: E | e.all_isas_attr = e.isas.*genls`
Wait! Can it also be written relationally?
`all_isas_attr = isas.*genls`
Let's check if `isas.*genls` is valid in Alloy!
Wait!
`isas` is `E -> C`.
`genls` is `C -> C`.
`*genls` is `C -> C`.
What is `isas.*genls`?
It is the relational composition of `isas` and `*genls`!
For any `e: E`, `e.(isas.*genls) = (e.isas).*genls`.
So `all_isas_attr = isas.*genls` is completely equivalent to `all e: E | e.all_isas_attr = e.isas.*genls`!
Wait, which one is better/more natural?
`all e: E | e.all_isas_attr = e.isas.*genls` is extremely clear and directly follows:
"The set of "C"s that related to an individual "E" using "all_isas_attr" is equal to the set of "C"s resulting from the "C"s that can be reached in zero or more steps of "genls" starting from the "C"s that are connected to the "E" via "isas"."
"to an individual E" -> `all e: E`!
"The set of "C"s that related to an individual "E" using "all_isas_attr" is equal to..."
`e.all_isas_attr = e.isas.*genls`!
That is an exact translation of the sentence!

Now let's check:
"Each element of "E" is related by "isas" to one or more elements of "C", meaning the element of "E" is a "C"."
In signature `E`:
`isas: some C` (or `isas: set C` with a fact `all e: E | some e.isas`).
In Alloy, signature field
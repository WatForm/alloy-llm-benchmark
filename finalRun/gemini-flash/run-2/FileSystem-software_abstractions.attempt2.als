`Root !in Directory.contents`
or `all d: Directory | Root !in d.contents`
or `no d: Directory | Root in d.contents`
All of these mean EXACTLY the same thing mathematically in Alloy!
Wait, does it matter which one of these equivalent forms we write?
In Alloy, the solver converts them all to the same SAT/relational constraints!
Whether you write:
`Root not in Directory.contents`
or
`all d: Directory | Root not in d.contents`
or
`no d: Directory | Root in d.contents`
they have the exact same set of instances.

Wait, let's check Constraint 2:
`The "Root" can reach every Object except itself through iterating the "contents" relation.`
In Alloy:
`Root.^contents = Object - Root`
Wait, could it be:
`Object - Root in Root.^contents`?
Wait, if `Object - Root in Root.^contents` and `Root not in Root.^contents` (from acyclic or contents acyclic):
Then `Root.^contents` cannot contain `Root`, and it contains all of `Object - Root`, so `Root.^contents = Object - Root`.
`Root.^contents = Object - Root` directly states:
The objects reachable from Root through contents is all Objects except Root!
Wait, is `Root.^contents = Object - Root` valid Alloy?
Yes! `Root` is a singleton (`one sig Root`), so `Root.^contents` is the relational join of `Root` with `^contents`, which gives the set of objects reachable from `Root`.
`Object - Root` is the set difference between `Object` and `Root`.
`Root.^contents = Object - Root` equates these two sets.

Wait! What if there are no objects other than Root?
If `Object = Root`, then `Object - Root = none`.
`Root.^contents = none`.
Everything works!

Wait, let's check Constraint 3:
`"contents" is acyclic.`
In Alloy:
How to write `"contents" is acyclic`?
Option A: `no iden & ^contents`
Option B: `all d: Directory | d not in d.^contents`
Option C: `all o: Object | o not in o.^contents`
Wait! Is there any difference between `no iden & ^contents` and `all o: Object | o not in o.^contents`?
No, in Alloy, `no iden & ^contents` is equivalent to `all o: Object | o not in o.^contents` because `contents` is on `Object`.
Wait! What if a cycle only involved Directories? Since `contents: Directory -> Object`, any cycle MUST involve at least one Directory (in fact, only directories can have contents).
So `all d: Directory | d not in d.^contents` is also equivalent to `all o: Object | o not in o.^contents`.
Wait, why not:
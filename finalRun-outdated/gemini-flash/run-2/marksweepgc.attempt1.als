-terminated or self-contained!
And for marked nodes (live nodes), their left and right pointers are preserved!
`n.(after.left) = n.(before.left)`
`n.(after.right) = n.(before.right)`
And `after.marked = before.marked`.
This is such an elegant, classic specification of Mark-and-Sweep!

Now let's look at the signatures and their definitions very carefully.
Let's re-read:
1. "There is a set of atoms called "Node"."
`sig Node {}`

2. "There is a set of atoms called "HeapState". Each "HeapState" is connected to at most one "Node" in a relation called "left". Each "HeapState" is connected to at most one "Node" in a relation called "right".
Each "HeapState" is connected to set of "Nodes" in the relation "marked".
Each "HeapState" matches to at most one "Node" by the relation "freeList"."

WAIT! Let's re-examine this!
Why did the prompt say:
"There is a set of atoms called "HeapState". Each "HeapState" is connected to at most one "Node" in a relation called "left". Each "HeapState" is connected to at most one "Node" in a relation called "right"."
WAIT!
Could `left` and `right` be:
`left: Node -> lone Node`?
Wait! In Alloy, how is `left: Node -> lone Node` defined inside `HeapState`?
```alloy
sig HeapState {
    left: Node -> lone Node,
    right: Node -> lone Node,
    marked: set Node,
    freeList: lone Node
}
```
Wait, could `left` be:
`left: Node lone -> lone Node`?
No, `left: Node -> lone Node` is the standard for a partial function from Node to Node.
Wait, what if someone wrote:
```alloy
sig HeapState {
    left: Node -> lone Node,
    right: Node -> lone Node,
    marked: set Node,
    freeList: lone Node
}
```
Wait! Look at the sentence in the prompt again:
"Each "HeapState" is connected to at most one "Node" in a relation called "left"."
Wait! Could it literally be:
Wait, why did it say:
"Each "HeapState" is connected to at most one "Node" in a relation called "left"."
Wait, is it possible that in some English description generator:
The generator had a bug when generating text for `left: Node -> lone Node`?
Let's see: if the generator does:
For each field `f: T1 -> lone T2`:
If it treats it as:
Domain: `HeapState`
Range: `Node` (ignoring intermediate `Node`)
Then it says: "Each HeapState is connected to at most one
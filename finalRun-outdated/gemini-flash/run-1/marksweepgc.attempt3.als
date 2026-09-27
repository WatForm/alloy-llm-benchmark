Wait, in CUP grammar:
Does `all x: e { ... }` parse?
Let's check Attempt 2's error message:
In Attempt 2, the parser reported:
`Syntax error in marksweepgc.attempt2.als at line 1 column 1:`
`Syntax error at the ` character. HEX: \u60)`
It stopped at line 1 column 1! So it didn't parse past line 1.
What about the grammar in Alloy?
Let's look at `edu.mit.csail.sdg.parser.CompParser`:
In Alloy:
```
ExprList ::= Expr | ExprList Expr
Block ::= "{" ExprList? "}"
QuantExpr ::= QUANT DeclList ("|" Expr | Block)
```
WAIT!
Does `Block` work as the body of a quantifier?
Wait! In Alloy:
Can you write `all x: X { expr1 expr2 }`?
WAIT! In Alloy, is a block `{ expr1 expr2 }` treated as an expression?
In Alloy:
A block `{ F1 F2 }` is an expression! It represents the conjunction `F1 and F2`.
Wait, in `all x: X | Block` or `all x: X Block`?
Wait! Look at `QuantExpr`:
In Alloy parser:
```
expr ::= ...
| ALL declList BAR expr
| ALL declList block
```
WAIT! Does Alloy support `ALL declList block` without `|`?
Let's verify!
In Alloy:
Wait! Can you do:
`all x: X { ... }`?
Let's think:
In Jackson's book:
Wait, in Jackson's book, every quantifier example has `|`!
E.g., `all x: X | ...`
`some x: X | ...`
Wait! What about `fact { some s1, s2: HeapState { ... } }`?
Wait, does `some s1, s2: HeapState { ... }` parse?
Wait! In Attempt 2:
`fact { some s1, s2: HeapState { clearMarks[h, s1] ... } }`
WAIT! Does `some s1, s2: HeapState | { ... }` or `some s1, s2: HeapState { ... }`?
Wait! Let's check `edu.mit.csail.sdg.parser`:
In `alloy.cup`:
Let's recall the exact rules in `alloy.cup`:
```cup
expr ::=
  ...
  | quant decls BAR expr
  | quant decls block
```
Wait! Does `quant decls block` exist in `alloy.cup`?
Wait, in Alloy, `block` is:
`block ::= LBRACE expr* RBRACE`
In `alloy.cup`:
```cup
expr ::= ...
  | quant
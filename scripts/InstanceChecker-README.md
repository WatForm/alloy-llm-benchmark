# InstanceChecker - README

* Problems: 
1) field in model is in parent but field in XML is in child subsigs 
2) field in model is in subsig, but field in XML is in parent sig 

These can be equivalent models and we want these instances to be satisfiable in the model + instance checking.


## 1) field in model is in parent but field in XML is in child subsigs 

* A model with only one f in the model, but multiple fs in XML becomes:

```
one sig S {}
sig A {
f: one S
}
one sig B extends A {}
one sig C extends A {}

one sig Sʃ0 extends S {}
one sig Bʃ0 extends B {}
one sig Cʃ0 extends C {}

fact {
    S = Sʃ0
    B = Bʃ0
    A = Bʃ0
      + Cʃ0
    C = Cʃ0
    B<:f = Bʃ0 -> Sʃ0
    C<:f = Cʃ0 -> Sʃ0
    (univ - C - B) <: f = none -> none
}
```
* From the XML, we have multiple equality statements each qualified by the child subsig.
* The last line is needed because parent A could have an additional atom in it in the model that is not part of B or C, and the XML would be a partial instance because there is more to "f".  To avoid this, we require the "rest" of f to be empty.
* Note: Alloy does not seem to determine that (univ - A) <: f = none -> none is trivially satisfied (and issue a warning) in the simple case of sig A { f : set S } with only one f in XML.


## 2) field in model is in subsig, but field in XML is in parent sig 

* A model with multiple field "f"s but only one "f" in the XML becomes the following. 
```
one sig S {}
sig A {
}
one sig B extends A {
f: one S
}
one sig C extends A {
f: one S
}

one sig Sʃ0 extends S {}
one sig Bʃ0 extends B {}
one sig Cʃ0 extends C {}

fact {
    S = Sʃ0
    B = Bʃ0
    A = Bʃ0
      + Cʃ0
    C = Cʃ0
    this/B <: f + this/C <: f = Bʃ0 -> Sʃ0
       + Cʃ0 -> Sʃ0

}
```
* The union of each use of f in the XML is qualified by its subsig on the lhs of the equality in the statement of the instance. 
* The fields in the model must be fields of subsigs of the parent sig in the XML for this to pass.  
* They could be subsigs at any level.
* Note that it is an error in Alloy: "Two overlapping signatures cannot have two fields with the same name", meaning that the "f"s have to have disjoint domains.  
* We cannot add `(univ - B - C) <: f = none -> none` in this case because the "f" is ambiguous in "(univ - B - C) <: f", but that's okay because we are guaranteed that there are no other parts of "f".

# InstanceChecker - README

* Cases 
0) field in model matches field name in XML
1) field in model is in parent but field in XML is in child subsigs 
2) field in model is in subsig, but field in XML is in parent sig 

These can be equivalent models and we want these instances to be satisfiable in the model + instance checking.

## 0) field in model matches field in XML (parent sigs have same name)

```
sig S {}
sig A {
}
sig B extends A {
f: S
}
sig C extends A {
f: S
}

one sig Sʃ0 extends S {}
one sig Bʃ0 extends B {}
one sig Cʃ0 extends C {}
one sig Cʃ1 extends C {}

fact {
    S = Sʃ0
    B = Bʃ0
    A = Bʃ0
      + Cʃ0
      + Cʃ1
    C = Cʃ0
      + Cʃ1
    B<:f = Bʃ0 -> Sʃ0
    C<:f = Cʃ0 -> Sʃ0
       + Cʃ1 -> Sʃ0
}
```

## 1) field in model is in parent but field in XML is in child subsigs 

* A model with only one f in the model, but multiple fs in XML becomes:

```
sig S {}
sig A {
f: S
}
sig B extends A {}
sig C extends A {}

one sig Sʃ0 extends S {}
one sig Bʃ0 extends B {}
one sig Cʃ0 extends C {}
one sig Cʃ1 extends C {}

fact {
    S = Sʃ0
    B = Bʃ0
    A = Bʃ0
      + Cʃ0
      + Cʃ1
    C = Cʃ0
      + Cʃ1
    B<:f = Bʃ0 -> Sʃ0
    C<:f = Cʃ0 -> Sʃ0
       + Cʃ1 -> Sʃ0
    (univ - B - C) <: f = none -> none
}
```
* From the XML, we have multiple equality statements each qualified by its sig (as defined by the XML).
* The last line ((univ - A) <: f = none -> none) is needed because parent A could have an additional atom in it in the model that is not part of B or C, and the XML would be a partial instance because there is more to "f".  To avoid this, we require the "rest" of f to be empty.



## 2) field in model is in subsig, but field in XML is in parent sig 

* A model with multiple field "f"s but only one "f" in the XML becomes the following. 
```
sig S {}
sig A {
}
sig B extends A {
f: S
}
sig C extends A {
f: S
}

one sig Sʃ0 extends S {}
one sig Bʃ0 extends B {}
one sig Cʃ0 extends C {}
one sig Cʃ1 extends C {}

fact {
    S = Sʃ0
    B = Bʃ0
    A = Bʃ0
      + Cʃ0
      + Cʃ1
    C = Cʃ0
      + Cʃ1
    B <: f = B<:(Cʃ0 -> Sʃ0
       + Bʃ0 -> Sʃ0
       + Cʃ1 -> Sʃ0)
    C <: f = C<:(Cʃ0 -> Sʃ0
       + Bʃ0 -> Sʃ0
       + Cʃ1 -> Sʃ0)
}
```
* We consider the tuples with respect to each of the potentially child fields in the model.
* The fields in the model must be fields of subsigs of the parent sig in the XML for this to pass.  
* They could be subsigs at any level.
* We cannot add `(univ - B - C) <: f = none -> none` in this case because the "f" is ambiguous in "(univ - B - C) <: f", but that's okay because we are guaranteed that there are no other parts of "f".

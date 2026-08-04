sig N {}

sig suivant: N -> N {}

fact Acyclic {
    all n: N | not n in (suivant.*N)
}

fact UniqueReachability {
    all n1, n2: N | 
        (n1 -> n2 in suivant) implies 
        (n1 -> n2 in suivant) and (n1 in (suivant^n2)) implies not n1 in (suivant^n2)
}
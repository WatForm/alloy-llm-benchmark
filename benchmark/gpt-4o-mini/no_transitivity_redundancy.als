sig N {}

sig suivant: N -> N {}

fact Acyclic {
    all n: N | not n in suivant.n.*
}

fact UniqueReachability {
    all n1, n2: N | 
        (n1 -> n2 in suivant) implies 
        no n: N | n in suivant.n.* and n in suivant.n1.*
}
sig E {
  isas : some C,
  all_isas_attr : set C
}

sig C {
  genls : set C
}

fact {
  -- genls is acyclic
  no c : C | c in c.^genls
  
  -- Every node has at most one parent
  all c : C | lone c.~genls
  
  -- At most one root
  lone { c : C | no c.~genls }
  
  -- all_isas_attr equals the reflexive transitive closure of genls applied to isas
  all e : E | e.all_isas_attr = e.isas.*genls
  
  -- For every element of E, no element of its isas set is reachable from another distinct element
  all e : E | no disj c1, c2 : e.isas | c1 in c2.*genls
}
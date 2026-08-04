sig A {}  
sig B {}  
sig C {}  

fun r: B -> C {   
    // r is a total function from B to C  
}  

fact {  
    all b: B | one r[b]  
}  

fact disjointSets {  
    A & B = {}  
    A & C = {}  
    B & C = {}  
}
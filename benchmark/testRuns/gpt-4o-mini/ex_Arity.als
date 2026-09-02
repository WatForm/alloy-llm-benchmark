sig A {}  
sig B {}  
sig C {}  

fun r: B -> C {}  

fact totalFunction {  
    all b: B | one r[b]  
}  

fact disjointSets {  
    A & B = {}  
    A & C = {}  
    B & C = {}  
}  
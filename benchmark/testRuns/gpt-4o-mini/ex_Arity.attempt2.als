sig A {}  
sig B {}  
sig C {}  

sig r extends B -> C {}  

fact totalFunction {  
    all b: B | one r[b]  
}  

fact disjointSets {  
    A & B = {}  
    A & C = {}  
    B & C = {}  
}
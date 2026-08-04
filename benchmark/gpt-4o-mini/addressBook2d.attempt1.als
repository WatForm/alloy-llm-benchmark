module model

sig Target {}  
sig Addr extends Target {}  
sig Name extends Target {}  
sig Alias {}  
sig Group {}  
sig Book { addr: Name -> Target }  

fact DisjointSets {  
    Addr + Name = Target  
    Addr ∩ Name = no Addr  
}  

fact Partition {  
    Alias in Name  
    Group in Name  
}  

fact BookAddr {  
    all b: Book |  
        no n: Name | n in b.addr[n]  

    all b: Book, a: Alias |  
        some n: Name | a in n implies one t: Target | (n -> t in b.addr)  
}  
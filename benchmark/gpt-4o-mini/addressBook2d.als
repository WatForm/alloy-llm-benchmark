module model

sig Target {}  
sig Addr extends Target {}  
sig Name extends Target {}  
sig Alias {}  
sig Group {}  
sig Book { addr: Name -> Target }  

fact DisjointSets {  
    Addr + Name = Target  
    Addr & Name = no Addr  
}  

fact Partition {  
    Alias in Name  
    Group in Name  
    Alias + Group = Name  
    Alias & Group = no Alias  
}  

fact BookAddr {  
    all b: Book |  
        no n: Name | n in b.addr[n]  

    all b: Book, a: Alias |  
        one t: Target | a in Addr implies (a -> t in b.addr)  
}
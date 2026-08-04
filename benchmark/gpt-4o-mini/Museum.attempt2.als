sig Picture {}  
sig Client {  
    loaned: set Picture,  
    desires: set Picture  
}  
sig Museum {  
    permanent: set Picture,  
    onDisplay: set Picture  
}  

// Assertions and Constraints  
fact {  
    // There is at least one Picture  
    some Picture  

    // There is at least one Client  
    some Client  

    // There is exactly one Museum  
    one Museum  

    // Every Picture is either onDisplay in the Museum or loaned to a Client  
    all p: Picture | p in Museum.onDisplay or some c: Client | p in c.loaned  

    // If a picture is permanent in a Museum, then it is onDisplay in that Museum  
    all p: Picture | p in Museum.permanent => p in Museum.onDisplay  

    // No Picture is both onDisplay in a Museum and loaned to any Client  
    all p: Picture, c: Client | p in Museum.onDisplay and p in c.loaned => false  

    // A Client's desires cannot equal the permanent set of the Museum  
    all c: Client | c.desires != Museum.permanent  

    // For every Client, no Picture is both in that client's desires and in that client's loaned set  
    all c: Client | no p: Picture | p in c.desires and p in c.loaned  

    // Every Picture that appears in the desires set of any Client is in the loaned set of at least one Client  
    all p: Picture | p in Client.desires => some c: Client | p in c.loaned  

    // For every two distinct Clients, no Picture is in both of their loaned sets  
    all c1, c2: Client | c1 != c2 => no p: Picture | p in c1.loaned and p in c2.loaned  
}  

run {}
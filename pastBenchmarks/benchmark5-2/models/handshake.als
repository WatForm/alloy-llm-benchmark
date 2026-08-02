module handshake

sig Person {spouse: Person, shaken: set Person}
one sig Jocelyn, Hilary extends Person {}

fact ShakingProtocol {
    all p: Person | no (p + p.spouse) & p.shaken
    all p, q: Person | p in q.shaken => q in p.shaken
    }

fact Spouses {
    all p, q: Person | p!=q => {
        p.spouse = q => q.spouse = p
        p.spouse != q.spouse
        }
    all p: Person {
        p.spouse.spouse = p
        p != p.spouse
        }
    }

fact Puzzle {
    all p,q: Person - Jocelyn | p!=q => #p.shaken != #q.shaken
    Hilary.spouse = Jocelyn
    }

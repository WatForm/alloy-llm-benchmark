sig Card {
    suit: Suit
}

sig Suit {}

sig hand {
    cards: set Card
} {
    #cards = 3 and 
    all c: cards | c.suit = cards.suit
} 
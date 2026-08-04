sig Card { suit: Suit }

sig Suit {}

sig hand {
    cards: Card
} {
    cards.size = 3 and 
    cards.suit = cards.suit[0]
}
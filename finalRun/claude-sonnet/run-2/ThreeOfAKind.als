sig Card {
    suit: one Suit
}

sig Suit {}

fact CardSuitDisjoint {
    no Card & Suit
}

one sig hand {
    cards: set Card
}

fact HandSize {
    #hand.cards = 3
}

fact HandSuit {
    one hand.cards.suit
}
sig Card {}
sig Suit {}

sig hand in Card {}

fact CardSuit {
    all c: Card | one suit[c]
}

fun suit[c: Card]: Suit { c.suit }

sig Card {
    suit: one Suit
}

fact HandSize {
    #hand = 3
}

fact HandSuit {
    one hand.suit
}
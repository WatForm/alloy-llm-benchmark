sig Card {suit: Suit}
sig Suit {}

sig hand in Card {}

fact ThreeOfAKind {
    #hand = 3 and #hand.suit = 1 
}

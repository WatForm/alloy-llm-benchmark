sig Card {
  suit: one Suit
}

sig Suit {}

sig hand in Card {}

fact {
  #hand = 3
  #hand.suit = 1
}
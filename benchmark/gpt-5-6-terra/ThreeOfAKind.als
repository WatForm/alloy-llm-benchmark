sig Card {
  suit: one Suit
}

sig Suit {}

sig hand in Card {}

fact {
  #hand = 3
  one hand.suit
}
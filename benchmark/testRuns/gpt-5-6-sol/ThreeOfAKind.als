sig Suit {}

sig Card {
  suit: one Suit
}

sig hand in Card {}

fact {
  #hand = 3
  one hand.suit
}
sig Suit {}

sig Card {
  suit: one Suit
}

sig hand in Card {}

fact HandConstraints {
  #hand = 3
  all c: hand | c.suit = hand.suit
}
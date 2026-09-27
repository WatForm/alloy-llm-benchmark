sig Suit {}

sig Card {
  suit: one Suit
}

pred ThreeOfAKind[hand: set Card] {
  #hand = 3
  all c: hand | c.suit = hand.suit
}

run ThreeOfAKind for 6
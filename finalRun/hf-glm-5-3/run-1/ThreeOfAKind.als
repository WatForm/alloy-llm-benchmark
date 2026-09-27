// Model of a hand of cards

sig Suit { }

sig Card {
  suit : one Suit
}

one sig hand in Card { }

fact {
  // hand contains exactly 3 elements
  #hand = 3
  // hand has exactly one suit
  one s : Suit | hand.suit = s
}
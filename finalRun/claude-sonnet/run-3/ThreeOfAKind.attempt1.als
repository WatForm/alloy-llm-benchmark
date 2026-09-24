sig Suit {}

sig Card {
  suit: one Suit
}

one sig hand {
  cards: set Card
}

fact {
  #hand.cards = 3
  #(hand.cards.suit) = 1
}
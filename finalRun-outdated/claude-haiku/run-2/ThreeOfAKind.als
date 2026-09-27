sig Card {
  suit: one Suit
}

sig Suit {}

one sig hand {
  cards: set Card
} {
  #cards = 3
  #(cards.suit) = 1
}
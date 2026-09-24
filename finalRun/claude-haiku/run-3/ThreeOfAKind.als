sig Suit {}

sig Card {
  suit: one Suit
}

sig hand {
  cards: set Card
} {
  #cards = 3
  #(cards.suit) = 1
}
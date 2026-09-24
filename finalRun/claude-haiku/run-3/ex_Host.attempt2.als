sig Host {}

sig Link {
    from: one Host,
    to: one Host
}

pred hasReverse(l: Link) {
    some l2: Link | l2.from = l.to and l2.to = l.from
}

fact ReverseRequired {
    all l: Link | hasReverse(l)
}
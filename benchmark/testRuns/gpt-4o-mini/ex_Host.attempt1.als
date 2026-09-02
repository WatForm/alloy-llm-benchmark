sig Host {}

sig Link {
    from: Host,
    to: Host
}

fact {
    all l: Link | 
        l.from != l.to and 
        Link.from = l.to and 
        Link.to = l.from
}

run {}
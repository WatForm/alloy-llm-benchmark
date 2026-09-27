sig Phone {
  requests: set Phone,
  connects: lone Phone,
  forward: lone Phone
}

fact {
  connects in {
    source, target: Phone |
      some requested: source.requests |
        target in requested.*forward and no target.forward
  }

  all target: Phone | lone connects.target
}
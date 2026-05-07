

sig Host {}
sig Link {from, to : Host}
	{some x: Link | x.@from = to and x.@to = from}

run {}

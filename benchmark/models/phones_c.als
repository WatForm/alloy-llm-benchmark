module homework/phones

sig Phone {
	requests: set Phone,
	connects: lone Phone,
	forward: lone Phone
}

fact ConnectsRequestsC {
	// all connections have matching requests (potentially forwarded)
	let noForward = {x : Phone | no x.forward} |
	let forwardedRequests = requests.(*forward :> noForward) |
	connects in forwardedRequests
	// no conference calls
	all x : Phone | lone connects.x
}

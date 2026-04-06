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



pred showC [] {
	// no self requests
	no requests & iden
	// at least three phones
	#Phone > 2
	// and some requests and connections
	some requests
	some connects & (requests.forward - requests)
}

run showC 

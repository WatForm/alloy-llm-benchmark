abstract sig Listing { }
sig Address extends Listing { }
sig Name extends Listing { }
sig Book {
	entry: set Name,
	listed: entry ->set Listing
}
fun lookup [b: Book, n: Name] : set Listing {n.^(b.listed)}

fact {all b:Book | all n:b.entry | lone b.listed[n] }

fact { all b:Book | all n,l:Name | l in lookup[b,n] implies l in b.entry }

fact { all b:Book | all n:b.entry | not n in lookup[b,n] }

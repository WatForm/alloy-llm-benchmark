/**
 * The pictures in a museum.
 */
some sig Picture{}

/**
 * Clients of the museum, in general, have some pictures loaned
 * to them and have desires for other pictures.
 */
some sig Client {
	loaned :	set Picture,
	desires	:	set Picture
}

/**
 * The museum has some pictures on display that can be loaned and
 * others in the permanent collection that must remain in the museum.
 *
 */
one sig Museum {
	permanent	: set Picture,
	onDisplay	: set Picture
}

/**
 *	All pictures are either on display or loaned out.
 */
fact F1_All_pictures_onDisplay_or_on_loan {
	all p: Picture |p in (Museum.onDisplay + Client.loaned )
}

/**
 *	All pictures in the permanent collection are always on display
 *	(they cannot be loaned to clients).
 *	Pictures on display other than the permanent collection are
 *	eligible for loaning to clients.
 */
fact F2_All_pictures_permanent_are_onDisplay {
  all p: Picture,m: Museum | p in m.permanent => p in m.onDisplay
}

/**
 *	A picture cannot be both on display and loaned out.
 *  (Similar to F1, but different expression)
 */
fact F3_No_picture_onDisplay_and_loaned {
	 no Museum.onDisplay & Client.loaned
}

/**
 *	No client can desire to borrow pictures that are
 *	in the permanent collection.
 */
fact F4_Client_cannot_desire_permanent_pictures {
	all c: Client|  c.desires != Museum.permanent
}	

/**
 *	A client cannot desire a picture he or she has been loaned.
 */
fact F5_Cannot_desire_what_you_are_loaned {
  all c : Client | no c.desires & c.loaned
}

/**
 *	All pictures some client desires are on loan.
 *	Note that a client *MAY* have been loaned a picture
 *	that no other client desires.
 */
fact F6_All_desired_pictures_are_loaned {
  all d:Client.desires, p:Picture |p in d => p in Client.loaned
}

/**
 *	Two different clients cannot be loaned the same picture.
 */
fact F7_No_loan_conflicts {
  all c1, c2 : Client | (c1 != c2) => (no c1.loaned & c2.loaned)
}

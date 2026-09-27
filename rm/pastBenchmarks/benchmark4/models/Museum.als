some sig Picture{}
 
some sig Client {
	loaned :	set Picture,
	desires	:	set Picture
}
 
one sig Museum {
	permanent	: set Picture,
	onDisplay	: set Picture
}
 
fact F1_All_pictures_onDisplay_or_on_loan {
	all p: Picture |p in (Museum.onDisplay + Client.loaned )
}
 
fact F2_All_pictures_permanent_are_onDisplay {
  all p: Picture,m: Museum | p in m.permanent => p in m.onDisplay
}
 
fact F3_No_picture_onDisplay_and_loaned {
	 no Museum.onDisplay & Client.loaned
}
 
fact F4_Client_cannot_desire_permanent_pictures {
	all c: Client|  c.desires != Museum.permanent
}	
 
fact F5_Cannot_desire_what_you_are_loaned {
  all c : Client | no c.desires & c.loaned
}
 
fact F6_All_desired_pictures_are_loaned {
  all d:Client.desires, p:Picture |p in d => p in Client.loaned
}
 
fact F7_No_loan_conflicts {
  all c1, c2 : Client | (c1 != c2) => (no c1.loaned & c2.loaned)
}

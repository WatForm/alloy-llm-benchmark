sig Name {}

sig Addr {}

sig Book {
  addr: Name -> lone Addr
}

pred show[b: Book] {
  #b.addr > 1
}

run show for 3 but exactly 1 Book, 3 Name, 3 Addr
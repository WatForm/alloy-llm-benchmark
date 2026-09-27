writes it as:
    ```alloy
    sig Book {
        entry: set Name,
        listed: entry -> lone Listing
    }
    ```
    Wait, could `listed: entry -> lone Listing` parse without any issues in Alloy 6?
    Let's verify:
    Does Alloy 6 accept:
    ```alloy
    abstract sig Listing {}
    sig Address, Name extends Listing {}

    sig Book {
        entry: set Name,
        listed: entry -> lone Listing
    }
    ```
    YES! In Alloy, `sig Book { entry: set Name, listed: entry -> lone Listing }` is standard, valid syntax!
    Wait, let's think: what if `b.entry` is empty?
    Then `b.entry -> lone Listing` is the empty relation `none -> Listing` which is `none`.
    So `b.listed` must be empty, which is correct because if `entry` is empty, there are no listings.

    Wait, what if Sentence 6 says:
    "A "Book" has "listed" information, which is a mapping between its "entry" and a set of "Listing"s."
    And then Sentence 8:
    "For every "Book" and every "Name" in the book's "entry", there is at most one "Listing" in the book's "listed" information for that "Name"."
    Could Sentence 8 have been a `fact` in the original model?
    Let's consider:
    If the original model was:
    ```alloy
    abstract sig Listing {}
    sig Address extends Listing {}
    sig Name extends Listing {}

    sig Book {
        entry: set Name,
        listed: entry -> lone Listing
    }
    ```
    Wait, why would the prompt say:
    "A "Book" has "listed" information, which is a mapping between its "entry" and a set of "Listing"s."
    If the sig was `listed: entry -> set Listing`, why?
    In Alloy, if someone writes:
    `listed: entry -> Listing` (which means `entry -> set Listing`)
    and then in a fact:
    `all b: Book, n: b.entry | lone n.(b.listed)`
    OR does Jackson write:
    Let's check Jackson's AddressBook:
    In Jackson's AddressBook:
    ```alloy
    sig Book {
        names: set Name,
        addr: names -> Target
    }
    ```
    Wait! In Jackson's book, Section 2.2:
    "sig Book {
        names: set Name,
        addr: names -> Target
    }"
    Wait, DOES Jackson put `names -> Target` or `names -> lone Target`?
    Wait! In Chapter 2, Jackson introduces:
    1. First version:
    `sig Book { names: set Name, addr: names ->
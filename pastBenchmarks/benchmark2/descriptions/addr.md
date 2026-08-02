This Alloy model defines data structures and relationships related to a simplified bibliographic system involving books and listings.

The abstract signature `Listing` represents entities that can be listed in the system. `Listing` is extended by two types of entities: `Address` and `Name`.

The signature `Book` records pieces of a book, consisting of `entry` and `listed`. `Entry` is a set of `Name` entities, representing the names associated with the book. `Listed` is a relation between `entry` and a set of `Listing` entities, indicating what Listings are associated with each name in a book.

The function `lookup` takes in a book (`b`) and a name (`n`) and returns a set of Listings for the given name in the given book.

Several constraints (facts) exist in the model:

1. For each book (`b`), and for each name (`n`) in the `entry` of the book, it is required that at most one Listing (`Listing`) is related to this name in the `listed` relation in the book.

2. For each book (`b`), and for each pair of names (`n`, `l`), if a name is in the result of the `lookup` function for a book and a given name, then this name must be in the `entry` of the book.

3. For each book (`b`), and for each name (`n`) in the `entry` of the book, this name must not be in the result of the `lookup` function for the book and this name. This indicates that a name in a book's entry cannot look itself up in the book.
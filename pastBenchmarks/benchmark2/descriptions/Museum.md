This Alloy model is about a museum and the relationships between its clientele and the artwork it possesses. This model includes the signatures `Client`, `Picture`, and `Museum`.

In this model, a picture is considered an arbitrary set of objects under the signature `Picture`.

The clients of the museum are represented by the signature `Client`. Each client can have a set of pictures which they have loaned from the museum, as well as a set of pictures which they desire to loan. These relationships are represented by the sets `loaned` and `desires` respectively.

The museum is represented by the signature `Museum`. The museum possesses a set of pictures which are part of its permanent collection, as well as a set of pictures which are currently on display. These relationships are represented by the sets `permanent` and `onDisplay` respectively.

There are several constraints about these relationships:

1. All pictures must be either on display at the museum or loaned out to a client.
2. Any picture in the permanent collection must always be on display. Pictures on display that do not belong to the permanent collection may be loaned out to clients.
3. A picture cannot both be on display at the museum and loaned out to a client simultaneously - it may exist in only one of these two states.
4. A client cannot desire to borrow a picture that belongs to the museum's permanent collection.
5. A client cannot desire a picture which is currently loaned to them.
6. Any picture a client desires must either be currently loaned out, or potentially loaned out again, but it cannot be a part of the museum's permanent collection. This implies that a client can be loaned a picture that no other client desires.
7. The same picture cannot be loaned out to more than one client at a time.

These constraints provide the complete set of rules for the model, which allow for understanding and analysis of the relationships between clients, museums and pictures.
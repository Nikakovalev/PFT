import Nat "mo:base/Nat";
import Option "mo:base/Option";

actor Storage {

  // Define a type for our data structure.
  type Record = {
    id: Nat;
    data: Text;
  };

  // Store the records in a hash map.
  stable var database: Trie.Trie<Nat, Record> = Trie.empty();

  // Variable to keep track of the next available ID.
  stable var nextId: Nat = 1;

  // Create a new record
  public func create(data: Text) : async Nat {
    let id = nextId;
    nextId += 1;

    let record = {
      id = id;
      data = data;
    };
    database := Trie.put(database, id, record);
    return id;
  };

  // Read a record by ID
  public query func read(id: Nat) : async ?Record {
    return Trie.get(database, id);
  };

  // Update a record by ID
  public func update(id: Nat, newData: Text) : async ?Record {
    switch Trie.get(database, id) {
      case (?record) {
        let updatedRecord = { id = id; data = newData };
        database := Trie.put(database, id, updatedRecord);
        return ?updatedRecord;
      };
      case null return null;
    };
  };

  // Delete a record by ID
  public func delete(id: Nat) : async Bool {
    let originalSize = Trie.size(database);
    database := Trie.remove(database, id);
    return Trie.size(database) < originalSize;
  };

  // Retrieve all records
  public query func list() : async [Record] {
    return Trie.values(database);
  };
};

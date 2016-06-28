# MongoStorage
A class for simple using models with MongoKitten 

Example
Init Mongo manager:

```
guard let mongoManager = MongoStorage() else {
   return
}
```

Implement DatabaseModel protocol for your model:
```
final class User: DatabaseModel {
    static var collectionName: String {
        return "Users"
    }
    
    var id: String?
    var name: String

    init(name: String) {
        self.name = name
    }
    
    convenience init?(document: Document) {
        guard let name = document["name"].stringValue nelse {
                return nil
        }

        self.init(name: name)
        let id = document["_id"].string
        self.id = id
    }

    func toDocument() -> Document {
        return ["name": Value(stringLiteral: name)]
    }
}
```

Now you can save it in Mongo collection:
```
 user = try mongoManager.add(model: User(name: "name"))
```

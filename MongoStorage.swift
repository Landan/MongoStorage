//
//  MongoStorage.swift
//  VaporApp
//
//  Created by landan on 6/27/16.
//
//


import BSON
import MongoKitten

protocol DatabaseModel {
    var id: String? {get set}
    static var collectionName: String {get}
    init?(document: Document)
    func toDocument() -> Document
}

class MongoStorage {
    
    typealias MongoServerCreator = () -> Server?
    typealias DatabaseCreator = ((mongoServer: Server) -> Database)

    private let mongoServer: Server
    private let dataBase: Database
    
    private class func defaultMongoServer() -> (() -> Server?) {
        return {
            do {
                return try Server(Constants.MongoStorage.host)
            }
            catch {
                return nil
            }
        }
    }
    
    private class func defaultDatabase() -> ((mongoServer: Server) -> Database) {
        return { mongoServer in
            mongoServer[Constants.MongoStorage.dataBaseName]
        }
    }
    
    init?(mongoServerCreator: MongoServerCreator = MongoStorage.defaultMongoServer(), database: DatabaseCreator = MongoStorage.defaultDatabase()) {
        
        guard let mongoServer = mongoServerCreator() else {
            return nil
        }
        
        self.mongoServer = mongoServer
        self.dataBase = database(mongoServer: mongoServer)
        
        do {
            try mongoServer.connect()
        } catch {
            Log.warning("Cannot connect to MongoDB")
        }
    }

}

extension MongoStorage {
    
    func get<T: DatabaseModel>(modelID: String) throws -> T? {
        let collection = dataBase[T.collectionName]
        guard let userDocument = try collection.findOne(matching: "_id" == ObjectId(modelID)) else {
            return nil
        }
    
        return T(document: userDocument)
    }
    
    func add<T: DatabaseModel>(model: T) throws -> T? {
        let collection = dataBase[T.collectionName]
        let userDocument = try collection.insert(model.toDocument())
        return T(document: userDocument)
    }
    
    func update<T: DatabaseModel>(model: T) throws {
        let collection = dataBase[T.collectionName]
        guard let modelID = model.id else {
            return
        }
        
        return try collection.update(matching: "_id" == ObjectId(modelID), to: model.toDocument())
    }
    
    func delete<T: DatabaseModel>(model: T) throws {
        let collection = dataBase[T.collectionName]
        guard let modelID = model.id else {
            return
        }
        try collection.remove(matching: "_id" == ObjectId(modelID))
    }
    
}
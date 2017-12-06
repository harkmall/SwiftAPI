//
//  User.swift
//  App
//
//  Created by Mark Hall on 2017-12-05.
//

import Vapor
import FluentProvider
import HTTP
import AuthProvider

final class User: Model {
    let storage = Storage()
    
    var name: String
    var age: Int
    var location: String
    var posts: Children<User, Post> {
        return children()
    }
    
    struct Keys {
        static let id = "id"
        static let name = "name"
        static let location = "location"
        static let age = "age"
    }
    
    init(name: String, location: String, age: Int) {
        self.name = name
        self.location = location
        self.age = age
    }
    
    init(row: Row) throws {
        name = try row.get(User.Keys.name)
        location = try row.get(User.Keys.location)
        age = try row.get(User.Keys.age)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(User.Keys.name, name)
        try row.set(User.Keys.location, location)
        try row.set(User.Keys.age, age)
        return row
    }
}

extension User: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(User.Keys.name)
            builder.string(User.Keys.location)
            builder.int(User.Keys.age)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension User: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(
            name: try json.get(User.Keys.name),
            location: try json.get(User.Keys.location),
            age: try json.get(User.Keys.age)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(User.Keys.id, id)
        try json.set(User.Keys.name, name)
        try json.set(User.Keys.location, location)
        try json.set(User.Keys.age, age)
        return json
    }
}

extension User: ResponseRepresentable {
    func makeResponse() throws -> Response {
        return try makeJSON().makeResponse()
    }
}

extension User: Updateable {
    public static var updateableKeys: [UpdateableKey<User>] {
        return [
            UpdateableKey(User.Keys.name, String.self) { user, name in
                user.name = name
            },
            UpdateableKey(User.Keys.age, Int.self) { user, age in
                user.age = age
            },
            UpdateableKey(User.Keys.location, String.self) { user, location in
                user.location = location
            }
        ]
    }
}



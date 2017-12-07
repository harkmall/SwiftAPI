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
    var email: String
    var password: String?
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
        static let email = "email"
        static let password = "password"
    }
    
    init(name: String, location: String, age: Int, email: String, password: String? = nil) {
        self.name = name
        self.location = location
        self.age = age
        self.email = email
        self.password = password
    }
    
    init(row: Row) throws {
        name = try row.get(User.Keys.name)
        location = try row.get(User.Keys.location)
        age = try row.get(User.Keys.age)
        email = try row.get(User.Keys.email)
        password = try row.get(User.Keys.password)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(User.Keys.name, name)
        try row.set(User.Keys.location, location)
        try row.set(User.Keys.age, age)
        try row.set(User.Keys.email, email)
        try row.set(User.Keys.password, password)
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
            builder.string(User.Keys.email)
            builder.string(User.Keys.password)
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
            age: try json.get(User.Keys.age),
            email: try json.get(User.Keys.email)
        )
        id = try json.get(User.Keys.id)
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(User.Keys.id, id)
        try json.set(User.Keys.name, name)
        try json.set(User.Keys.location, location)
        try json.set(User.Keys.age, age)
        try json.set(User.Keys.email, email)
        return json
    }
}

extension User: ResponseRepresentable { }

// MARK: Password

// This allows the User to be authenticated
// with a password. We will use this to initially
// login the user so that we can generate a token.
extension User: PasswordAuthenticatable {
    var hashedPassword: String? {
        return password
    }
    
    public static var passwordVerifier: PasswordVerifier? {
        get { return _userPasswordVerifier }
        set { _userPasswordVerifier = newValue }
    }
}

// store private variable since storage in extensions
// is not yet allowed in Swift
private var _userPasswordVerifier: PasswordVerifier? = nil

// MARK: Request

extension Request {
    /// Convenience on request for accessing
    /// this user type.
    /// Simply call `let user = try req.user()`.
    func user() throws -> User {
        return try auth.assertAuthenticated()
    }
}

// MARK: Token

// This allows the User to be authenticated
// with an access token.
extension User: TokenAuthenticatable {
    typealias TokenType = Token
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



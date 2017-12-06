//
//  UserController.swift
//  App
//
//  Created by Mark Hall on 2017-12-05.
//

import Foundation
import Vapor
import HTTP
import Sessions

struct UserController {
    func addRoutes(to drop: Droplet) {
        let usersGroup = drop.grouped("users")
        usersGroup.get("", handler: allUsers)
        usersGroup.post("", handler: saveUser)
        usersGroup.delete("", handler: deleteAllUsers)
        usersGroup.get(User.parameter, handler: getUser)
        usersGroup.delete(User.parameter, handler: deleteUser)
        usersGroup.patch(User.parameter, handler: updateUser)
        usersGroup.put(User.parameter, handler: replaceUser)
        usersGroup.get(User.parameter, "posts", handler: posts)
    }
    
    func allUsers(_ req: Request) throws -> ResponseRepresentable {
        return try User.all().makeJSON()
    }
    
    func saveUser(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.user()
        try user.save()
        return user
    }
    
    func getUser(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.userParam()
        return user
    }
    
    func deleteUser(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.userParam()
        try user.delete()
        return Response(status: .ok)
    }
    
    func deleteAllUsers(_ req: Request) throws -> ResponseRepresentable {
        try User.makeQuery().delete()
        return Response(status: .ok)
    }
    
    func updateUser(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.userParam()
        try user.update(for: req)
        try user.save()
        return user
    }
    
    func replaceUser(_ req: Request) throws -> ResponseRepresentable {
        let new = try req.user()
        let user = try req.userParam()

        user.name = new.name
        user.location = new.location
        user.age = new.age
        try user.save()
        
        return user
    }
    
    func posts(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.userParam()
        return try user.posts.all().makeJSON()
    }
    
}

extension Request {
    func user() throws -> User {
        guard let json = json else {
            throw Abort.badRequest
        }
        return try User(json: json)
    }
    
    func userParam() throws -> User {
        return try parameters.next(User.self)
    }
}

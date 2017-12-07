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
import AuthProvider

struct UserController {
    func addRoutes(to drop: Droplet) {
        
        let usersGroup = drop.grouped("users")
       
        let passwordProtectedGroup = usersGroup.grouped(PasswordAuthenticationMiddleware(User.self))
        
        passwordProtectedGroup.post("login") { req in
            print("something")
            let user = try req.user()
            let token = try Token.generate(for: user)
            try token.save()
            return token
        }
        
        let tokenProtectedGroup = usersGroup.grouped(TokenAuthenticationMiddleware(User.self))
        
        tokenProtectedGroup.get("") { req in
            return try User.all().makeJSON()
        }
        
        tokenProtectedGroup.get("/me") { req in
            let user = try req.user()
            return user
        }
        
        tokenProtectedGroup.delete("/me") { req in
            let user = try req.user()
            try user.delete()
            return Response(status: .ok)
        }
        
        tokenProtectedGroup.patch("/me") { req in
            let user = try req.user()
            try user.update(for: req)
            try user.save()
            return user
        }
        
        tokenProtectedGroup.put("/me") { req in
            guard let json = req.json else {
                throw Abort.badRequest
            }
            let new = try User(json: json)
            let user = try req.user()
            
            user.name = new.name
            user.location = new.location
            user.age = new.age
            try user.save()
            
            return user
        }
        
        tokenProtectedGroup.get("posts") { req in
            let user = try req.user()
            return try user.posts.all().makeJSON()
        }
        
        
        usersGroup.post("") { req in
            
            guard let json = req.json else {
                throw Abort(.badRequest)
            }
            
            let user = try User(json: json)
            
            // ensure no user with this email already exists
            guard try User.makeQuery().filter("email", user.email).first() == nil else {
                throw Abort(.badRequest, reason: "A user with that email already exists.")
            }
            
            // require a plaintext password is supplied
            guard let password = json["password"]?.string else {
                throw Abort(.badRequest)
            }
            
            // hash the password and set it on the user
            user.password = try drop.hash.make(password.makeBytes()).makeString()
            
            try user.save()
            return user
        }
        
        usersGroup.delete("") { req in
            try User.makeQuery().delete()
            return Response(status: .ok)
        }
    }
    
}


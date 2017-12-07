import Vapor
import HTTP
import AuthProvider

struct PostController {
    func addRoutes(to drop: Droplet) {
        let postsGroup = drop.grouped("posts").grouped(TokenAuthenticationMiddleware(User.self))
        
        postsGroup.get("") { req in
            return try Post.all().makeJSON()
        }
        
        postsGroup.post("") { req in
            let post = try req.post()
            try post.save()
            return post
        }
        
        postsGroup.get(Post.parameter) { req in
            let post = try req.postParam()
            return post
        }
        
        postsGroup.delete(Post.parameter) { req in
            let post = try req.postParam()
            try post.delete()
            return Response(status: .ok)
        }
        
        postsGroup.delete("") { req in
            try Post.makeQuery().delete()
            return Response(status: .ok)
        }
        
        postsGroup.patch(Post.parameter) { req in
            let post = try req.postParam()
            try post.update(for: req)
            try post.save()
            return post
        }
        
        postsGroup.put(Post.parameter) { req in
            let post = try req.postParam()
            let new = try req.post()
            
            post.content = new.content
            try post.save()
            
            return post
        }
        
        postsGroup.get(Post.parameter, "user") { req in
            let post = try req.postParam()
            guard let user = try post.user.get() else {
                throw Abort.notFound
            }
            return user
        }
    }
}

extension Request {
    func post() throws -> Post {
        guard let json = json else {
            throw Abort.badRequest
        }
        let authedUser = try user()
        return try Post(content: json.get(Post.Keys.content), user: authedUser)
    }
    
    func postParam() throws -> Post {
        return try parameters.next(Post.self)
    }
}

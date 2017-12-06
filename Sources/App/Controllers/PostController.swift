import Vapor
import HTTP


struct PostController {
    func addRoutes(to drop: Droplet) {
        let postsGroup = drop.grouped("posts")
        postsGroup.get("", handler: allPosts)
        postsGroup.post("", handler: savePost)
        postsGroup.get(Post.parameter, handler: getPost)
        postsGroup.delete(Post.parameter, handler: deletePost)
        postsGroup.delete("", handler: deleteAllPosts)
        postsGroup.patch(Post.parameter, handler: updatePost)
        postsGroup.put(Post.parameter, handler: replacePost)
        postsGroup.get(Post.parameter, "user", handler: user)
    }
    
    func allPosts(_ req: Request) throws -> ResponseRepresentable {
        return try Post.all().makeJSON()
    }
    
    func savePost(_ req: Request) throws -> ResponseRepresentable {
        let post = try req.post()
        try post.save()
        return post
    }

    func getPost(_ req: Request) throws -> ResponseRepresentable {
        let post = try req.postParam()
        return post
    }
    
    func deletePost(_ req: Request) throws -> ResponseRepresentable {
        let post = try req.postParam()
        try post.delete()
        return Response(status: .ok)
    }
    
    func deleteAllPosts(_ req: Request) throws -> ResponseRepresentable {
        try Post.makeQuery().delete()
        return Response(status: .ok)
    }
    
    func updatePost(_ req: Request) throws -> ResponseRepresentable {
        let post = try req.postParam()
        try post.update(for: req)
        try post.save()
        return post
    }

    func replacePost(_ req: Request) throws -> ResponseRepresentable {
        let post = try req.postParam()
        let new = try req.post()
        
        post.content = new.content
        try post.save()
        
        return post
    }
    
    func user(_ req: Request) throws -> ResponseRepresentable {
        let post = try req.postParam()
        guard let user = try post.user.get() else {
            throw Abort.notFound
        }
        return user
    }
}

extension Request {
    func post() throws -> Post {
        guard let json = json else {
            throw Abort.badRequest
        }
        return try Post(json: json)
    }
    
    func postParam() throws -> Post {
        return try parameters.next(Post.self)
    }
}

import Vapor

extension Droplet {
    func setupRoutes() throws {
        
        let userController = UserController()
        userController.addRoutes(to: self)
        
        let postController = PostController()
        postController.addRoutes(to: self)
        
    }
}

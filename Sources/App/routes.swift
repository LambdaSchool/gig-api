import Crypto
import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // public routes
    let userController = UserController()
    router.post("api", "users", use: userController.create)
    router.post("api", "login", use: userController.login)
    
    // bearer / token auth protected routes
    let bearer = router.grouped(User.tokenAuthMiddleware())
    let gigController = GigController()
    
    bearer.get("api", "gigs", "my", use: gigController.index)
    bearer.get("api", "gigs", use: gigController.allGigsHandler)
    bearer.post("api", "gigs", use: gigController.create)
    bearer.delete("api", "gigs", Gig.parameter, use: gigController.delete)
}
import Routing
import Vapor
import Authentication
import Crypto

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {

    router.get("policy") { req -> Future<View> in
        return try req.view().render("policy")
    }
    
    let basicAuthMiddleware = User.basicAuthMiddleware(using: BCrypt)
    let guardAuthMiddleware = User.guardAuthMiddleware()
    let basicAuthRouter = router.grouped([basicAuthMiddleware, guardAuthMiddleware])
    
    //users
    let uCtrller = UserController()
    let usersRouter = router.grouped("api","users")
    let crtUsersRouter = basicAuthRouter.grouped("api","users")

    //用户账号
    usersRouter.post(User.self, at: "register",use: uCtrller.userRegistration)
    usersRouter.post(User.self, at: "login", use: uCtrller.userLogin)
    crtUsersRouter.get("nickname",Int.parameter, use: uCtrller.getUserNickName) //用户id
    crtUsersRouter.post(UserProfile.self, at: "modifyprofile", use: uCtrller.modifyProfile)

    //用户屏蔽主题
    crtUsersRouter.get("countofblockedtopics",Int.parameter, use: uCtrller.getCountsOfBlockedTopics)
    crtUsersRouter.get("blockedtopics",Int.parameter,Int.parameter, use: uCtrller.getBlockedTopics) //用户id,批次n
    crtUsersRouter.get("deleteblockedtopic",Int.parameter, use: uCtrller.deleteBlockedTopic) //条目id

    //用户屏蔽用户
    crtUsersRouter.get("countofblockedusers",Int.parameter, use: uCtrller.getCountsOfBlockedUsers)
    crtUsersRouter.get("blockedusers",Int.parameter,Int.parameter, use: uCtrller.getBlockedUsers) //用户id,批次n
    crtUsersRouter.get("deleteblockeduser",Int.parameter, use: uCtrller.deleteBlockedUser) //条目id

    //用户屏蔽整站
    crtUsersRouter.get("countofblockedhosts",Int.parameter, use: uCtrller.getCountsOfBlockedHosts)
    crtUsersRouter.get("blockedhosts",Int.parameter,Int.parameter, use: uCtrller.getBlockedHosts) //用户id,批次n
    crtUsersRouter.get("deleteblockedhost",Int.parameter, use: uCtrller.deleteBlockedHost) //条目id

    //用户屏蔽单页
    crtUsersRouter.get("countofblockedlinks",Int.parameter, use: uCtrller.getCountsOfBlockedLinks)
    crtUsersRouter.get("blockedlinks",Int.parameter,Int.parameter, use: uCtrller.getBlockedLinks) //用户id,批次n
    crtUsersRouter.get("deleteblockedlink",Int.parameter, use: uCtrller.deleteBlockedLink) //条目id

    //topics
    let tpCtrller = TopicController()
    let crtTopicsRouter = basicAuthRouter.grouped("api","topics")
    
    crtTopicsRouter.post("create", use: tpCtrller.createTopic)
    crtTopicsRouter.post("update", use: tpCtrller.updateTopic)
    crtTopicsRouter.post("createpure", use: tpCtrller.createTopicPure)
    crtTopicsRouter.post("unsubscribe",Int.parameter,Int.parameter, use: tpCtrller.unsubscribeTopic) //用户id，主题id
    crtTopicsRouter.post("subscribe",Int.parameter,Int.parameter, use: tpCtrller.subscribeTopic) //用户id，主题id
    crtTopicsRouter.post("block",Int.parameter,Int.parameter, use: tpCtrller.blockTopic) //用户id，主题id

    crtTopicsRouter.get("topicviaid",Int.parameter,use: tpCtrller.getTopicViaID)
    crtTopicsRouter.get("creator", String.parameter, use: tpCtrller.getTopicCreator)
    crtTopicsRouter.get("subscribers",String.parameter, use: tpCtrller.getTopicSubscriber)
    crtTopicsRouter.get("createdtopics",Int.parameter, use: tpCtrller.getCreatedTopics) //用户id

    crtTopicsRouter.get("subscribedtopics",Int.parameter,Int.parameter, use: tpCtrller.getSubscribedTopics) //用户id，批次
    crtTopicsRouter.get("othertopics",Int.parameter,Int.parameter, use: tpCtrller.getOtherTopics) //用户id，批次

    crtTopicsRouter.get("subscribedtopics",Int.parameter,Int.parameter,String.parameter, use: tpCtrller.getSubscribedTopicsWithKey) //用户id，批次,关键词
    crtTopicsRouter.get("othertopics",Int.parameter,Int.parameter,String.parameter, use: tpCtrller.getOtherTopicsWithKey) //用户id，批次,关键词

    crtTopicsRouter.get("subscribedtotalpages",Int.parameter, use: tpCtrller.getTotalPagesOfSubscribedTopics) //用户id
    crtTopicsRouter.get("othertotalpages",Int.parameter, use: tpCtrller.getTotalPagesOfOtherTopics) //用户id

    crtTopicsRouter.get("subscribedtotalpages",Int.parameter,String.parameter,  use: tpCtrller.getTotalPagesOfSubscribedTopicsWithKey) //用户id
    crtTopicsRouter.get("othertotalpages",Int.parameter,String.parameter,  use: tpCtrller.getTotalPagesOfOtherTopicsWithKey) //用户id
    
    //replies
    let reCtrller = ReplyController()
    let crtRepliesRouter = basicAuthRouter.grouped("api","replies")
    
    crtRepliesRouter.post(Reply.self, at: "add", use: reCtrller.addReplyToTopic)
    crtRepliesRouter.post(Blocks.self, at: "blocks", use: reCtrller.addBlocks)
    crtRepliesRouter.post(UserPinReplyPair.self, at: "submitpin", use: reCtrller.submitPin)
    
    crtRepliesRouter.get("getpins",Int.parameter,Int.parameter,use: reCtrller.getPins) //回复id，用户id
    crtRepliesRouter.get("firstbatch",Int.parameter,Int.parameter, use: reCtrller.getReplies) //主题id，用户id
    crtRepliesRouter.get("newer",Int.parameter,Int.parameter,Int.parameter,use: reCtrller.getNewerReplies) //主题id，用户id，临界回复id
    crtRepliesRouter.get("older",Int.parameter,Int.parameter,Int.parameter,use: reCtrller.getOlderReplies) //主题id，用户id，临界回复id
}

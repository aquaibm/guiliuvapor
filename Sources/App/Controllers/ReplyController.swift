//
//  ReplyController.swift
//  App
//
//  Created by Li Fumin on 2018/7/2.
//

import Foundation
import Vapor
import Fluent
import FluentPostgreSQL



struct ReplyController {
    
    //Post
    func addReplyToTopic(req: Request, reply: Reply) throws -> Future<HTTPResponseStatus> {
        return Reply.query(on: req).filter(\.posterID == reply.posterID)
            .filter(\.topicID == reply.topicID)
            .filter(\.link == reply.link).first().flatMap({ existingReply in
            guard existingReply == nil else {
                throw Abort(.badRequest, reason: "已在该主题下发布过该链接，不能重复发布。", identifier: nil)
            }
                
            
            
            return reply.save(on: req).transform(to: .created)
        })
    }
    
    func addBlocks(req: Request, blocks: Blocks) throws -> Future<HTTPResponseStatus> {
        let a = GlobalWhiteUser.query(on: req).all()
        let b = GlobalWhiteHost.query(on: req).all()
        let c = GlobalWhiteLink.query(on: req).all()
        return flatMap(to: HTTPResponseStatus.self, a, b, c, { (wUsers, wHosts, wLinks) in
            let userIDs = wUsers.map {$0.userID}
            let hosts = wHosts.map {$0.host}
            let links = wLinks.map {$0.link}
            
            var list = [Future<HTTPResponseStatus>]()
            if let userID =  blocks.blockedUserID {
                if userIDs.contains(userID) {
                    throw Abort(HTTPResponseStatus.badRequest, reason: "不能屏蔽该白名单用户", identifier: nil)
                }
                
                let blUser = BlockedUser(ownerID: blocks.ownerID, blockedUserID: userID).save(on: req).transform(to: HTTPResponseStatus.created)
                list.append(blUser)
            }
            
            if let host = blocks.blockedHost {
                if hosts.contains(host) {
                    throw Abort(HTTPResponseStatus.badRequest, reason: "不能屏蔽该白名单网址", identifier: nil)
                }
                
                let blHost = BlockedHost(ownerID: blocks.ownerID, blockedHost: host).save(on: req).transform(to: HTTPResponseStatus.created)
                list.append(blHost)
            }
            
            if let link = blocks.blockedLink {
                if links.contains(link) {
                    throw Abort(HTTPResponseStatus.badRequest, reason: "不能屏蔽该白名单网址", identifier: nil)
                }
                
                //如果整个网站都被屏蔽了，就没必要再针对其下单个子网址了。
                if blocks.blockedHost == nil {
                    let blLink = BlockedLink(ownerID: blocks.ownerID, blockedLink: link).save(on: req).transform(to: HTTPResponseStatus.created)
                    list.append(blLink)
                }
                
                if let flag = blocks.isOffensive, flag == true {
                    let pair = ReportedLink(ownerID: blocks.ownerID, reportedLink: link).save(on: req).transform(to: HTTPResponseStatus.created)
                    list.append(pair)
                }
            }
            
            return list.flatten(on: req).map { status in
                let results1 = status.map { $0.code }
                let count1 = results1.count
                let results2 = results1.filter { $0 == 201 }
                let count2 = results2.count
                if count1 == count2 {
                    return HTTPResponseStatus.created
                }
                else {
                    throw Abort(HTTPResponseStatus.internalServerError, reason: "\(count1)个子项请求，仅\(count2)个成功", identifier: nil)
                }
            }
        })
    }
    
    
    func submitPin(_ req: Request, pair: UserPinReplyPair) throws -> Future<ReplyPins> {
        //搜索是已有关系
        return UserReplyPivot.query(on: req).filter(\.userID == pair.userID).filter(\.replyID == pair.replyID).first().flatMap({ (pivot) in
            var finalPivot: UserReplyPivot
            if pivot == nil{
                //全新的
                finalPivot = UserReplyPivot(userID: pair.userID, replyID: pair.replyID, interactionType: pair.interactionType)
            }
            else {
                finalPivot = pivot!
                if finalPivot.interactionType == pair.interactionType {
                    //相同的，即取消重置为0
                    finalPivot.interactionType = 0
                }
                else {
                    finalPivot.interactionType = pair.interactionType
                }
            }
            
            //保存新的关系
            return finalPivot.save(on: req).flatMap({ _ in
                //搜索对应reply条目的点评数，并将结果返回
                return UserReplyPivot.query(on: req).filter(\.replyID == pair.replyID).all().map({ (pivots) in
                    let likes = pivots.filter{ $0.interactionType == 1}.count
                    let dislikes = pivots.filter{ $0.interactionType == 2}.count
                    return ReplyPins(like: likes, dislike: dislikes,mySelection: finalPivot.interactionType)
                })
            })
        })
    }
    
    //Get
    func getPins(req: Request) throws -> Future<ReplyPins> {
        let replyID = try req.parameters.next(Int.self)
        let userID = try req.parameters.next(Int.self)
        //搜索reply条目的点评数
        return UserReplyPivot.query(on: req).filter(\.replyID == replyID).all().flatMap({ (pivots) in
            let likes = pivots.filter{ $0.interactionType == 1}.count
            let dislikes = pivots.filter{ $0.interactionType == 2}.count
            //搜索用户对该条目的选择
            return UserReplyPivot.query(on: req).filter(\.replyID == replyID).filter(\.userID == userID).first().map({ userPivot in
                if let userPivotT = userPivot {
                    return ReplyPins(like: likes, dislike: dislikes,mySelection: userPivotT.interactionType)
                }
                else {
                    return ReplyPins(like: likes, dislike: dislikes,mySelection: 0)
                }
            })
        })
    }
    
    func getReplies(_ req: Request) throws -> Future<[Reply]> {
        let topicID = try req.parameters.next(Int.self)
        let userID = try req.parameters.next(Int.self)
        
        //获取对应的用户和主题，以及公共黑名单
        let a = Topic.find(topicID, on: req)
        let b = User.find(userID, on: req)
        let c = GlobalBlockedHost.query(on: req).all()
        let d = GlobalBlockedLink.query(on: req).all()
        let e = GlobalBlockedUser.query(on: req).all()
        return flatMap(to: [Reply].self,a,b,c,d,e, { topic, user,gbHosts,gbLinks,gbUsers  in
            guard let topicT = topic, let userT = user else {
                throw Abort(.badRequest, reason: "相应主题或用户不存在", identifier: nil)
            }
            
            //获取用户的屏蔽列表
            let f = try userT.blockedUsers.query(on: req).all()
            let g = try userT.blockedHosts.query(on: req).all()
            let h = try userT.blockedLinks.query(on: req).all()
            return flatMap(to: [Reply].self,f,g,h, { (bUsers, bHosts, bLinks) in
                let userIDs = bUsers.map {$0.blockedUserID}
                let hosts = bHosts.map {$0.blockedHost}
                let links = bLinks.map {$0.blockedLink}
                let gHosts = gbHosts.map {$0.blockedHost}
                let gLinks = gbLinks.map {$0.blockedLink}
                let gUsers = gbUsers.map {$0.blockedUserID}
                
                return try topicT.replies.query(on: req).group(.and, closure: { (builder) in
                    builder.filter(\Reply.posterID !~ userIDs)
                    builder.filter(\Reply.host !~ hosts)
                    builder.filter(\Reply.link !~ links)
                    builder.filter(\Reply.host !~ gHosts)
                    builder.filter(\Reply.link !~ gLinks)
                    builder.filter(\Reply.posterID !~ gUsers)
                }).sort(\.id, .descending).range(0..<20).all()
            })
        })
    }
    
    
    func getNewerReplies(_ req: Request) throws -> Future<[Reply]> {
        let topicID = try req.parameters.next(Int.self)
        let userID = try req.parameters.next(Int.self)
        let lastReplyID = try req.parameters.next(Int.self)
        
        //获取对应的用户和主题，以及公共黑名单
        let a = Topic.find(topicID, on: req)
        let b = User.find(userID, on: req)
        let c = GlobalBlockedHost.query(on: req).all()
        let d = GlobalBlockedLink.query(on: req).all()
        let e = GlobalBlockedUser.query(on: req).all()
        return flatMap(to: [Reply].self,a,b,c,d,e, { topic, user,gbHosts,gbLinks,gbUsers  in
            guard let topicT = topic, let userT = user else {
                throw Abort(.badRequest, reason: "相应主题或用户不存在", identifier: nil)
            }
            
            //获取用户的屏蔽列表
            let f = try userT.blockedUsers.query(on: req).all()
            let g = try userT.blockedHosts.query(on: req).all()
            let h = try userT.blockedLinks.query(on: req).all()
            return flatMap(to: [Reply].self,f,g,h, { (bUsers, bHosts, bLinks) in
                let userIDs = bUsers.map {$0.blockedUserID}
                let hosts = bHosts.map {$0.blockedHost}
                let links = bLinks.map {$0.blockedLink}
                let gHosts = gbHosts.map {$0.blockedHost}
                let gLinks = gbLinks.map {$0.blockedLink}
                let gUsers = gbUsers.map {$0.blockedUserID}
                
                return try topicT.replies.query(on: req).group(.and, closure: { (builder) in
                    builder.filter(\Reply.posterID !~ userIDs)
                    builder.filter(\Reply.host !~ hosts)
                    builder.filter(\Reply.link !~ links)
                    builder.filter(\Reply.host !~ gHosts)
                    builder.filter(\Reply.link !~ gLinks)
                    builder.filter(\Reply.posterID !~ gUsers)
                    builder.filter(\.id > lastReplyID)
                }).sort(\.id, .ascending).range(0..<20).all()
            })
        })
    }
    
    func getOlderReplies(_ req: Request) throws -> Future<[Reply]> {
        let topicID = try req.parameters.next(Int.self)
        let userID = try req.parameters.next(Int.self)
        let firstReplyID = try req.parameters.next(Int.self)
        
        //获取对应的用户和主题，以及公共黑名单
        let a = Topic.find(topicID, on: req)
        let b = User.find(userID, on: req)
        let c = GlobalBlockedHost.query(on: req).all()
        let d = GlobalBlockedLink.query(on: req).all()
        let e = GlobalBlockedUser.query(on: req).all()
        return flatMap(to: [Reply].self,a,b,c,d,e, { topic, user,gbHosts,gbLinks,gbUsers  in
            guard let topicT = topic, let userT = user else {
                throw Abort(.badRequest, reason: "相应主题或用户不存在", identifier: nil)
            }
            
            //获取用户的屏蔽列表
            let f = try userT.blockedUsers.query(on: req).all()
            let g = try userT.blockedHosts.query(on: req).all()
            let h = try userT.blockedLinks.query(on: req).all()
            return flatMap(to: [Reply].self,f,g,h, { (bUsers, bHosts, bLinks) in
                let userIDs = bUsers.map {$0.blockedUserID}
                let hosts = bHosts.map {$0.blockedHost}
                let links = bLinks.map {$0.blockedLink}
                let gHosts = gbHosts.map {$0.blockedHost}
                let gLinks = gbLinks.map {$0.blockedLink}
                let gUsers = gbUsers.map {$0.blockedUserID}
                
                return try topicT.replies.query(on: req).group(.and, closure: { (builder) in
                    builder.filter(\Reply.posterID !~ userIDs)
                    builder.filter(\Reply.host !~ hosts)
                    builder.filter(\Reply.link !~ links)
                    builder.filter(\Reply.host !~ gHosts)
                    builder.filter(\Reply.link !~ gLinks)
                    builder.filter(\Reply.posterID !~ gUsers)
                    builder.filter(\.id < firstReplyID)
                }).sort(\.id, .descending).range(0..<20).all()
            })
        })
    }

}

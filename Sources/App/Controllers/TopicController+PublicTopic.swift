//
//  TopicController+GetBatchTopics.swift
//  App
//
//  Created by Li Fumin on 2018/12/22.
//

import Foundation
import Vapor
import Fluent
import FluentPostgreSQL

extension TopicController {

    func getTotalPagesOfOtherTopics(req: Request) throws -> Future<Int> {
        let userID = try req.parameters.next(Int.self)
        //找到对应用户
        return User.find(userID, on: req).flatMap({ (user) in
            guard let userT = user else {
                throw Abort(.notFound, reason: "没有此用户", identifier: nil)
            }
            //找到用户的订阅主题列表和屏蔽列表
            let a = try userT.subscribedTopics.query(on: req).all()
            let b = try userT.blockedTopics.query(on: req).all()
            let c = GlobalBlockedTopic.query(on: req).all()
            return flatMap(to: Int.self, a, b, c, { subscrTopics, bTopics, gbTopics in
                let subscrIDs = subscrTopics.compactMap { $0.id }
                let bIDs = bTopics.compactMap { $0.blockedTopicID }
                let gbTopicIDs = gbTopics.compactMap { $0.blockedTopicID }

                //进行过滤并返回结果
                return Topic.query(on: req).filter(\Topic.id !~ gbTopicIDs).filter(\Topic.id !~ subscrIDs).filter(\Topic.id !~ bIDs).all().map({ topics in
                    return topics.count/50
                })
            })
        })
    }

    func getTotalPagesOfOtherTopicsWithKey(req: Request) throws -> Future<Int> {
        let userID = try req.parameters.next(Int.self)
        let key = try req.parameters.next(String.self).removingPercentEncoding

        //找到对应用户
        return User.find(userID, on: req).flatMap({ (user) in
            guard let userT = user else {
                throw Abort(.notFound, reason: "没有此用户", identifier: nil)
            }
            //找到用户的订阅主题列表和屏蔽列表
            let a = try userT.subscribedTopics.query(on: req).all()
            let b = try userT.blockedTopics.query(on: req).all()
            let c = GlobalBlockedTopic.query(on: req).all()
            return flatMap(to: Int.self, a, b, c, { subscrTopics, bTopics, gbTopics in
                let subscrIDs = subscrTopics.compactMap { $0.id }
                let bIDs = bTopics.compactMap { $0.blockedTopicID }
                let gbTopicIDs = gbTopics.compactMap { $0.blockedTopicID }

                //进行过滤并返回结果
                if let tKey = key, tKey.isEmpty == false {
                    return Topic.query(on: req).group(.or){
                        $0.filter(\Topic.name ~~ tKey).filter(\Topic.description ~~ tKey)
                        }.filter(\Topic.id !~ gbTopicIDs).filter(\Topic.id !~ subscrIDs).filter(\Topic.id !~ bIDs).all().map({ topics in
                            return topics.count/50
                        })
                }
                else {
                    return Topic.query(on: req).filter(\Topic.id !~ gbTopicIDs).filter(\Topic.id !~ subscrIDs).filter(\Topic.id !~ bIDs).all().map({ topics in
                        return topics.count/50
                    })
                }
            })
        })
    }

    func getOtherTopics(req: Request) throws -> Future<[Int]> {
        let userID = try req.parameters.next(Int.self)
        let batch = try req.parameters.next(Int.self) // 0,1,2,3,...
        //找到对应用户
        return User.find(userID, on: req).flatMap({ (user) in
            guard let userT = user else {
                throw Abort(.notFound, reason: "没有此用户", identifier: nil)
            }
            //找到用户的订阅主题列表和屏蔽列表
            let a = try userT.subscribedTopics.query(on: req).all()
            let b = try userT.blockedTopics.query(on: req).all()
            let c = GlobalBlockedTopic.query(on: req).all()
            return flatMap(to: [Int].self, a, b, c, { subscrTopics, bTopics, gbTopics in
                let subscrIDs = subscrTopics.compactMap { $0.id }
                let bIDs = bTopics.compactMap { $0.blockedTopicID }
                let gbTopicIDs = gbTopics.compactMap { $0.blockedTopicID }

                //进行过滤并返回结果
                let start = 0 + 50*batch
                let end = 50 + 50*batch
                return Topic.query(on: req).filter(\Topic.id !~ gbTopicIDs).filter(\Topic.id !~ subscrIDs).filter(\Topic.id !~ bIDs).sort(\Topic.createdAt, .descending).range(start..<end).all().map({ tps in
                    return tps.compactMap{ $0.id }
                })
            })
        })
    }

    func getOtherTopicsWithKey(req: Request) throws -> Future<[Int]> {
        let userID = try req.parameters.next(Int.self)
        let batch = try req.parameters.next(Int.self) // 0,1,2,3,...
        let key = try req.parameters.next(String.self).removingPercentEncoding
        //找到对应用户
        return User.find(userID, on: req).flatMap({ (user) in
            guard let userT = user else {
                throw Abort(.notFound, reason: "没有此用户", identifier: nil)
            }
            //找到用户的订阅主题列表和屏蔽列表
            let a = try userT.subscribedTopics.query(on: req).all()
            let b = try userT.blockedTopics.query(on: req).all()
            let c = GlobalBlockedTopic.query(on: req).all()
            return flatMap(to: [Int].self, a, b, c, { subscrTopics, bTopics, gbTopics in
                let subscrIDs = subscrTopics.compactMap { $0.id }
                let bIDs = bTopics.compactMap { $0.blockedTopicID }
                let gbTopicIDs = gbTopics.compactMap { $0.blockedTopicID }

                //进行过滤并返回结果
                let start = 0 + 50*batch
                let end = 50 + 50*batch
                if let tKey = key, tKey.isEmpty == false {
                    return Topic.query(on: req).group(.or){
                        $0.filter(\Topic.name ~~ tKey).filter(\Topic.description ~~ tKey)
                        }.filter(\Topic.id !~ gbTopicIDs).filter(\Topic.id !~ subscrIDs).filter(\Topic.id !~ bIDs).sort(\Topic.createdAt, .descending).range(start..<end).all().map({ tps in
                            return tps.compactMap{ $0.id }
                        })
                }
                else {
                    return Topic.query(on: req).filter(\Topic.id !~ gbTopicIDs).filter(\Topic.id !~ subscrIDs).filter(\Topic.id !~ bIDs).sort(\Topic.createdAt, .descending).range(start..<end).all().map({ tps in
                        return tps.compactMap{ $0.id }
                    })
                }
            })
        })
    }
}

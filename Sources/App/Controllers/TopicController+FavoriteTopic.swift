//
//  TopicController+FavoriteTopic.swift
//  App
//
//  Created by Li Fumin on 2019/2/11.
//

import Foundation
import Vapor
import Fluent
import FluentPostgreSQL

extension TopicController {
    func getTotalPagesOfSubscribedTopics(request: Request) throws -> Future<Int> {
        let userID = try request.parameters.next(Int.self)
        //找到对应用户和公共主题黑名单
        let a = User.find(userID, on: request)
        let b = GlobalBlockedTopic.query(on: request).all()
        return flatMap(to: Int.self, a, b, { user, gbTopics in
            guard let userT = user else {
                throw Abort(.notFound, reason: "没有此用户", identifier: nil)
            }
            //进行过滤并返回结果
            let gbTopicIDs = gbTopics.compactMap { $0.blockedTopicID }
            return try userT.subscribedTopics.query(on: request).filter(\Topic.id !~ gbTopicIDs).all().map({ topics in
                return topics.count/50
            })
        })
    }

    func getTotalPagesOfSubscribedTopicsWithKey(request: Request) throws -> Future<Int> {
        let userID = try request.parameters.next(Int.self)
        let key = try request.parameters.next(String.self).removingPercentEncoding

        //找到对应用户和公共主题黑名单
        let a = User.find(userID, on: request)
        let b = GlobalBlockedTopic.query(on: request).all()
        return flatMap(to: Int.self, a, b, { user, gbTopics in
            guard let userT = user else {
                throw Abort(.notFound, reason: "没有此用户", identifier: nil)
            }
            //进行过滤并返回结果
            let gbTopicIDs = gbTopics.compactMap { $0.blockedTopicID }
            if let tKey = key, tKey.isEmpty == false {
                return try userT.subscribedTopics.query(on: request).group(.or){
                    $0.filter(\Topic.name ~~ tKey).filter(\Topic.description ~~ tKey)
                    }.filter(\Topic.id !~ gbTopicIDs).all().map({ topics in
                        return topics.count/50
                    })
            }
            else {
                return try userT.subscribedTopics.query(on: request).filter(\Topic.id !~ gbTopicIDs).all().map({ topics in
                    return topics.count/50
                })
            }
        })
    }
    
    func getSubscribedTopics(request: Request) throws -> Future<[Int]> {
        let userID = try request.parameters.next(Int.self)
        let batch = try request.parameters.next(Int.self) // 0,1,2,3,...
        //找到对应用户和公共主题黑名单
        let a = User.find(userID, on: request)
        let b = GlobalBlockedTopic.query(on: request).all()
        return flatMap(to: [Int].self, a, b, { user, gbTopics in
            guard let userT = user else {
                throw Abort(.notFound, reason: "没有此用户", identifier: nil)
            }
            //进行过滤并返回结果
            let gbTopicIDs = gbTopics.compactMap { $0.blockedTopicID }
            let start = 0 + 50*batch
            let end = 50 + 50*batch

            return try userT.subscribedTopics.query(on: request).filter(\Topic.id !~ gbTopicIDs).sort(\Topic.createdAt, .descending).range(start..<end).all().map({ tps in
                return tps.compactMap{ $0.id }
            })
        })
    }

    func getSubscribedTopicsWithKey(request: Request) throws -> Future<[Int]> {
        let userID = try request.parameters.next(Int.self)
        let batch = try request.parameters.next(Int.self) // 0,1,2,3,...
        let key = try request.parameters.next(String.self).removingPercentEncoding
        //找到对应用户和公共主题黑名单
        let a = User.find(userID, on: request)
        let b = GlobalBlockedTopic.query(on: request).all()
        return flatMap(to: [Int].self, a, b, { user, gbTopics in
            guard let userT = user else {
                throw Abort(.notFound, reason: "没有此用户", identifier: nil)
            }
            //进行过滤并返回结果
            let gbTopicIDs = gbTopics.compactMap { $0.blockedTopicID }
            let start = 0 + 50*batch
            let end = 50 + 50*batch

            if let tKey = key, tKey.isEmpty == false {
                return try userT.subscribedTopics.query(on: request).group(.or){
                    $0.filter(\Topic.name ~~ tKey).filter(\Topic.description ~~ tKey)
                    }.filter(\Topic.id !~ gbTopicIDs).sort(\Topic.createdAt, .descending).range(start..<end).all().map({ tps in
                        return tps.compactMap{ $0.id }
                    })
            }
            else {
                return try userT.subscribedTopics.query(on: request).filter(\Topic.id !~ gbTopicIDs).sort(\Topic.createdAt, .descending).range(start..<end).all().map({ tps in
                    return tps.compactMap{ $0.id }
                })
            }
        })
    }
}

//
//  TopicController+TotalPage.swift
//  App
//
//  Created by Li Fumin on 2018/12/22.
//

import Foundation
import Vapor
import Fluent
import FluentPostgreSQL

extension TopicController {

    func unsubscribeTopic(_ req: Request) throws -> Future<HTTPResponseStatus> {
        let userID = try req.parameters.next(Int.self)
        let topicID = try req.parameters.next(Int.self)

        return UserTopicPivot.query(on: req).filter(\.userID == userID).filter(\.topicID == topicID).first().flatMap({ pivot in
            guard let pivotT = pivot else {
                throw Abort(.badRequest, reason: "找不到对应的订阅关系", identifier: nil)
            }

            return pivotT.delete(on: req).transform(to: .ok)
        })
    }

    func subscribeTopic(_ req: Request) throws -> Future<HTTPResponseStatus> {
        let userID = try req.parameters.next(Int.self)
        let topicID = try req.parameters.next(Int.self)

        return UserTopicPivot.query(on: req).filter(\.userID == userID).filter(\.topicID == topicID).first().flatMap({ (pivot) in
            if pivot == nil {
                let pivot = UserTopicPivot(userID: userID, topicID: topicID)
                return pivot.save(on: req).transform(to: .ok)
            }
            else {
                throw Abort(.forbidden, reason: "不能重复订阅", identifier: nil)
            }
        })
    }


    func blockTopic(_ req: Request) throws -> Future<HTTPResponseStatus> {
        let userID = try req.parameters.next(Int.self)
        let topicID = try req.parameters.next(Int.self)

        //找到对应主题，提取主题名称
        return Topic.find(topicID, on: req).flatMap({ topic in
            guard let topicT = topic else {
                throw Abort(.badRequest, reason: "找不到对应的主题", identifier: nil)
            }

            return BlockedTopic(ownerID: userID, blockedTopicID: topicID, blockedTopicName: topicT.name).save(on: req).transform(to: .ok)
        })

    }

    func updateTopic(req: Request) throws -> Future<HTTPResponseStatus> {
        return try req.content.decode(Topic.self).flatMap({ incomingTopic in
            //传过来的incomingTopic只包含了有限的几个必备参数，而忽略了其余不必要的参数，注意不能直接替代。
            guard let tid = incomingTopic.id else {
                throw Abort(.badRequest, reason: "主题id无效", identifier: nil)
            }
            return Topic.find(tid, on: req).flatMap({ existingTopic in
                guard var topicT = existingTopic else {
                    throw Abort(.badRequest, reason: "对应主题不存在", identifier: nil)
                }

                topicT.avatar = incomingTopic.avatar
                topicT.description = incomingTopic.description
                return topicT.save(on: req).transform(to: .ok)
            })
        })
    }

}

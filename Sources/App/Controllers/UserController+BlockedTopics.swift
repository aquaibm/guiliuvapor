//
//  UserController+BlockedTopic.swift
//  App
//
//  Created by Li Fumin on 2019/2/10.
//

import Foundation
import Vapor
import Fluent
import FluentPostgreSQL
import Crypto

extension UserController {

    func getCountsOfBlockedTopics(req: Request) throws -> Future<Int> {
        let userID = try req.parameters.next(Int.self)
        return BlockedTopic.query(on: req).filter(\.ownerID == userID).all().map({ list in
            return list.count
        })
    }

    //批次由零开始
    func getBlockedTopics(req: Request) throws -> Future<[BlockedTopic]> {
        let userID = try req.parameters.next(Int.self)
        let batch = try req.parameters.next(Int.self)
        let start = 0 + 50*batch
        let end = 50 + 50*batch
        return BlockedTopic.query(on: req).filter(\.ownerID == userID).sort(\.createdAt, .descending).range(start..<end).all()
    }

    func deleteBlockedTopic(req: Request) throws -> Future<Topic> {
        let id = try req.parameters.next(Int.self)
        return BlockedTopic.find(id, on: req).flatMap({ bTopic in
            guard let bTopicT = bTopic else {
                throw Abort(.notFound, reason: "删除条目id无效", identifier: nil)
            }
            return bTopicT.delete(on: req).flatMap({ _ in
                return Topic.find(bTopicT.blockedTopicID, on: req).map({ tp in
                    guard let tpT = tp else {
                        throw Abort(.notFound, reason: "哎呀，发生了不应该发生的意外错误。", identifier: nil)
                    }
                    return tpT
                })
            })
        })
    }
}

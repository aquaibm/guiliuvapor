//
//  TopicController+Relations.swift
//  App
//
//  Created by Li Fumin on 2019/3/6.
//

import Foundation
import Vapor
import Fluent
import FluentPostgreSQL


extension TopicController {
    func getCreatedTopics(request: Request) throws -> Future<[Topic]> {
        let userID = try request.parameters.next(Int.self)
        return User.find(userID, on: request).flatMap({ (user) in
            guard let userT = user else {
                throw Abort(.notFound, reason: "没有此用户", identifier: nil)
            }
            return try userT.createdTopics.query(on: request).all()
        })
    }

    func getTopicCreator(_ req: Request) throws -> Future<User> {
        let name = try req.parameters.next(String.self)
        guard let convert = name.removingPercentEncoding else {
            throw Abort(.badRequest, reason: "主题名称无效", identifier: nil)
        }
        return Topic.query(on: req).filter(\.name == convert).first().flatMap({ (topic) in
            guard let topic = topic else {
                throw Abort(.notFound, reason: "主题不存在", identifier: nil)
            }

            return topic.creator.get(on: req)
        })
    }

    func getTopicSubscriber(_ req: Request) throws -> Future<[User]> {
        let name = try req.parameters.next(String.self)
        guard let convertedName = name.removingPercentEncoding else {
            throw Abort(.badRequest, reason: "主题名称无效", identifier: nil)
        }

        return Topic.query(on: req).filter(\.name == convertedName).first().flatMap({ (topic) in
            guard let topic = topic else {
                throw Abort(.notFound, reason: "主题不存在", identifier: nil)
            }

            return try topic.subcribers.query(on: req).all()
        })
    }
}

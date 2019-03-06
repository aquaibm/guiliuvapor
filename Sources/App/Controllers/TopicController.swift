//
//  TopicController.swift
//  App
//
//  Created by Li Fumin on 2018/6/5.
//

import Foundation
import Vapor
import Fluent
import FluentPostgreSQL

struct TopicController {
    func createTopic(request: Request) throws -> Future<Topic> {
        return try request.content.decode(Topic.self).flatMap({ (newTopic) in
            return Topic.query(on: request).filter(\.name == newTopic.name).first().flatMap({ (existingTopic) in
                guard existingTopic == nil else {
                    throw Abort(.forbidden, reason: "主题已存在，不能重复创建", identifier: nil)
                }
                
                return newTopic.save(on: request).flatMap({ (topic) in
                    //创建新主题后即时订阅，同时防止重复订阅
                    let tID = try topic.requireID()
                    return UserTopicPivot.query(on: request).filter(\.userID == topic.creatorID).filter(\.topicID == tID).first().flatMap({ (pivot) in
                        if pivot == nil {
                            let pivot = try UserTopicPivot(userID: topic.creatorID, topicID: topic.requireID())
                            return pivot.save(on: request).transform(to: topic)
                        }
                        else {
                            throw Abort(.forbidden, reason: "不能重复订阅", identifier: nil)
                        }
                    })
                })
            })
        })
    }
    
    func createTopicPure(request: Request) throws -> Future<Topic> {
        return try request.content.decode(Topic.self).flatMap({ (newTopic) in
            return Topic.query(on: request).filter(\.name == newTopic.name).first().flatMap({ (existingTopic) in
                guard existingTopic == nil else {
                    throw Abort(.forbidden, reason: "主题已存在，不能重复创建", identifier: nil)
                }
                
                return newTopic.save(on: request)
            })
        })
    }
}

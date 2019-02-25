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
    //Get
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
            throw Abort(.expectationFailed, reason: "主题名称无效", identifier: nil)
        }
        return Topic.query(on: req).filter(\.name == convert).first().flatMap({ (topic) in
            guard let topic = topic else {
                throw Abort(.badRequest, reason: "主题不存在", identifier: nil)
            }
            
            return topic.creator.get(on: req)
        })
    }
    
    func getTopicSubscriber(_ req: Request) throws -> Future<[User]> {
        let name = try req.parameters.next(String.self)
        guard let convertedName = name.removingPercentEncoding else {
            throw Abort(.expectationFailed, reason: "主题名称无效", identifier: nil)
        }
        
        return Topic.query(on: req).filter(\.name == convertedName).first().flatMap({ (topic) in
            guard let topic = topic else {
                throw Abort(.badRequest, reason: "主题不存在", identifier: nil)
            }
            
            return try topic.subcribers.query(on: req).all()
        })
    }
    
    
    //Post
    func createTopic(request: Request) throws -> Future<Topic> {
        return try request.content.decode(Topic.self).flatMap({ (newTopic) in
            return Topic.query(on: request).filter(\.name == newTopic.name).first().flatMap({ (existingTopic) in
                guard existingTopic == nil else {
                    throw Abort(.badRequest, reason: "主题已存在，不能重复创建", identifier: nil)
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
                            throw Abort(.badRequest, reason: "不能重复订阅", identifier: nil)
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
                    throw Abort(.badRequest, reason: "主题已存在，不能重复创建", identifier: nil)
                }
                
                return newTopic.save(on: request)
            })
        })
    }
}

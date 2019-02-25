//
//  Subject.swift
//  App
//
//  Created by Li Fumin on 2018/6/5.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct Topic: PostgreSQLModel{
    var id: Int?
    
    var name: String
    var creatorID: User.ID
    var description: String?
    var avatar: Data?
    
    var createdAt: Date?
    var updatedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    
    init(name: String,creatorID: User.ID,description: String?) {
        self.name = name
        self.creatorID = creatorID
        self.description = description
    }
}




extension Topic: Content {}
extension Topic: Parameter {}
extension Topic: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void>{
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.creatorID, to: \User.id)
        }
    }
}



extension Topic {
    var creator: Parent<Topic,User> {
        return parent(\.creatorID)
    }
    
    var replies: Children<Topic,Reply> {
        return children(\.topicID)
    }
}


extension Topic {
    var subcribers: Siblings<Topic,User,UserTopicPivot> {
        return siblings()
    }
}

//
//  Reply.swift
//  App
//
//  Created by Li Fumin on 2018/6/5.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct Reply: PostgreSQLModel {
    var id: Int?
    
    var posterID: Int
    var topicID: Int
    var link: String
    
    var host: String
    var title: String
    var summary: String
    
    var canBlock = true
    
    var createdAt: Date?
    var updatedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt } 
    
    init(posterID: Int,posterName:String, topicID: Int, link: String,host: String,title: String,summary: String) {
        self.posterID = posterID
        self.topicID = topicID
        self.link = link
        
        self.host = host
        self.title = title
        self.summary = summary
    }
}


extension Reply: Content {}
extension Reply: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void>{
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.posterID, to: \User.id)
            builder.reference(from: \.topicID, to: \Topic.id)
        }
    }
}




extension Reply {
    var topic: Parent<Reply,Topic> {
        return parent(\.topicID)
    }
    
    var poster: Parent<Reply,User> {
        return parent(\.posterID)
    }
}


extension Reply {
    var interactingUsers: Siblings<Reply, User, UserReplyPivot> {
        return siblings()
    }
}


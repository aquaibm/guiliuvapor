//
//  BlockedTopic.swift
//  App
//
//  Created by Li Fumin on 2018/8/19.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct BlockedTopic: PostgreSQLModel{
    var id: Int?
    var ownerID: Int
    var blockedTopicID: Int
    var blockedTopicName: String
    
    var createdAt: Date?
    var updatedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    
    init(ownerID: Int, blockedTopicID: Int, blockedTopicName: String) {
        self.ownerID = ownerID
        self.blockedTopicID = blockedTopicID
        self.blockedTopicName = blockedTopicName
    }
}

extension BlockedTopic: Content {}
extension BlockedTopic: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void>{
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.ownerID, to: \User.id)
        }
    }
}




extension BlockedTopic {
    var owner: Parent<BlockedTopic,User> {
        return parent(\.ownerID)
    }
}

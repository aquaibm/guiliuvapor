//
//  BlockedUser.swift
//  App
//
//  Created by Li Fumin on 2018/7/29.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct BlockedUser: PostgreSQLModel{
    var id: Int?
    
    var ownerID: Int
    var blockedUserID: Int
    var blockedUserName: String?
    
    var createdAt: Date?
    var updatedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    
    init(ownerID: Int, blockedUserID: Int) {
        self.ownerID = ownerID
        self.blockedUserID = blockedUserID
    }
}

extension BlockedUser: Content {}
extension BlockedUser: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void>{
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.ownerID, to: \User.id)
        }
    }
}




extension BlockedUser {
    var owner: Parent<BlockedUser,User> {
        return parent(\.ownerID)
    }
}

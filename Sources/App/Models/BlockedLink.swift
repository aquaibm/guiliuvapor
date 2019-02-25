//
//  BlockedLink.swift
//  App
//
//  Created by Li Fumin on 2018/7/29.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct BlockedLink: PostgreSQLModel{
    var id: Int?
    var ownerID: Int
    var blockedLink: String
    
    var createdAt: Date?
    var updatedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    
    init(ownerID: Int, blockedLink: String) {
        self.ownerID = ownerID
        self.blockedLink = blockedLink
    }
}


extension BlockedLink: Content {}
extension BlockedLink: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void>{
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.ownerID, to: \User.id)
        }
    }
}




extension BlockedLink {
    var owner: Parent<BlockedLink,User> {
        return parent(\.ownerID)
    }
}

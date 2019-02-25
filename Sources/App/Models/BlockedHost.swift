//
//  BlockedHost.swift
//  App
//
//  Created by Li Fumin on 2018/7/29.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct BlockedHost: PostgreSQLModel{
    var id: Int?
    var ownerID: Int
    var blockedHost: String
    
    var createdAt: Date?
    var updatedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    
    init(ownerID: Int, blockedHost: String) {
        self.ownerID = ownerID
        self.blockedHost = blockedHost
    }
}


extension BlockedHost: Content {}
extension BlockedHost: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void>{
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.ownerID, to: \User.id)
        }
    }
}




extension BlockedHost {
    var owner: Parent<BlockedHost,User> {
        return parent(\.ownerID)
    }
}

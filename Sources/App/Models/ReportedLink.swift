//
//  ReportedLink.swift
//  App
//
//  Created by Li Fumin on 2018/8/4.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct ReportedLink: PostgreSQLModel{
    var id: Int?

    var ownerID: Int
    var reportedLink: String
    
    var createdAt: Date?
    var updatedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    
    init(ownerID: Int, reportedLink: String) {
        self.ownerID = ownerID
        self.reportedLink = reportedLink
    }
}


extension ReportedLink: Content {}
extension ReportedLink: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void>{
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.ownerID, to: \User.id)
        }
    }
}




extension ReportedLink {
    var owner: Parent<ReportedLink,User> {
        return parent(\.ownerID)
    }
}

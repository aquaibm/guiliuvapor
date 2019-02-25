//
//  UserTopicPivot.swift
//  App
//
//  Created by Li Fumin on 2018/6/15.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct UserTopicPivot: PostgreSQLPivot {
    var id: Int?

    var userID: Int
    var topicID: Int
    typealias Left = User
    typealias Right = Topic
    static let leftIDKey: LeftIDKey = \.userID
    static let rightIDKey: RightIDKey = \.topicID
    
    var createdAt: Date?
    var updatedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    
    init(userID: Int, topicID: Int) {
        self.userID = userID
        self.topicID = topicID
    }
}


extension UserTopicPivot: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void>{
        return Database.create(self, on: connection, closure: { (builder) in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.id)
            builder.reference(from: \.topicID, to: \Topic.id)
        })
    }
}

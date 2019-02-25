//
//  UserReplyPivot.swift
//  App
//
//  Created by Li Fumin on 2018/7/4.
//

import Foundation
import Vapor
import FluentPostgreSQL

//用于记录用户对链接内容的点赞类型
struct UserReplyPivot: PostgreSQLPivot {
    var id: Int?

    var userID: Int
    var replyID: Int
    var interactionType: Int  //1 = like, 2 = dislike , 3 = offensive
    typealias Left = User
    typealias Right = Reply
    static let leftIDKey: LeftIDKey = \.userID
    static let rightIDKey: RightIDKey = \.replyID
    
    var createdAt: Date?
    var updatedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    
    init(userID: Int, replyID: Int, interactionType: Int) {
        self.userID = userID
        self.replyID = replyID
        self.interactionType = interactionType
    }
}



extension UserReplyPivot: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void>{
        return Database.create(self, on: connection, closure: { (builder) in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.id)
            builder.reference(from: \.replyID, to: \Reply.id)
        })
    }
}


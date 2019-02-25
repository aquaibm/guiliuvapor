//
//  GlobalBlockedUser.swift
//  App
//
//  Created by Li Fumin on 2018/8/31.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct GlobalBlockedUser: PostgreSQLModel,Migration{
    var id: Int?
    var blockedUserID: Int
    
    var createdAt: Date?
    var updatedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    
    init(blockedUserID: Int) {
        self.blockedUserID = blockedUserID
    }
}

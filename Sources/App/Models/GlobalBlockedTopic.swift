//
//  GlobalBlockedTopic.swift
//  App
//
//  Created by Li Fumin on 2018/8/31.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct GlobalBlockedTopic: PostgreSQLModel,Migration{
    var id: Int?
    var blockedTopicID: Int
    
    var createdAt: Date?
    var updatedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    
    init(blockedTopicID: Int) {
        self.blockedTopicID = blockedTopicID
    }
}

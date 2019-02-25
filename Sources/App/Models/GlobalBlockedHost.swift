//
//  GlobalBlockedHost.swift
//  App
//
//  Created by Li Fumin on 2018/8/7.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct GlobalBlockedHost: PostgreSQLModel,Migration{
    var id: Int?
    
    var blockedHost: String
    
    var createdAt: Date?
    var updatedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    
    init(blockedHost: String) {
        self.blockedHost = blockedHost
    }
}

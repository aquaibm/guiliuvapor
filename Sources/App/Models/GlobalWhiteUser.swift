//
//  GlobalWhiteUserID.swift
//  App
//
//  Created by Li Fumin on 2018/8/7.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct GlobalWhiteUser: PostgreSQLModel,Migration{
    var id: Int?
    var userID: Int
    
    var createdAt: Date?
    var updatedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    
    init(userID: Int) {
        self.userID = userID
    }
}

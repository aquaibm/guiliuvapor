//
//  GlobalWhiteHost.swift
//  App
//
//  Created by Li Fumin on 2018/8/7.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct GlobalWhiteHost: PostgreSQLModel,Migration{
    var id: Int?
    var host: String
    
    var createdAt: Date?
    var updatedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    
    init(host: String) {
        self.host = host
    }
}

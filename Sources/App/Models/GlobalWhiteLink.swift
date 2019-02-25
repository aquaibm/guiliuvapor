//
//  GlobalWhiteLink.swift
//  App
//
//  Created by Li Fumin on 2018/8/7.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct GlobalWhiteLink: PostgreSQLModel,Migration{
    var id: Int?
    var link: String
    
    var createdAt: Date?
    var updatedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    
    init(link: String) {
        self.link = link
    }
}

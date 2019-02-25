//
//  User.swift
//  App
//
//  Created by Li Fumin on 2018/6/2.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

struct User: PostgreSQLModel,BasicAuthenticatable{
    var id: Int?
    
    var email: String
    var password: String
    
    var nickName: String?
    var cellPhone: String?
    var avatar: Data?
    
    static let usernameKey: WritableKeyPath<User, String> = \.email
    static let passwordKey: WritableKeyPath<User, String> = \.password
    
    var createdAt: Date?
    var updatedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}



extension User: Content {}
extension User: Parameter {}
extension User: Migration {}

extension User {
    var createdTopics: Children<User,Topic> {
        return children(\.creatorID)
    }
    
    var createdReplies: Children<User,Reply> {
        return children(\.posterID)
    }
    
    var blockedTopics: Children<User,BlockedTopic> {
        return children(\.ownerID)
    }
    
    var blockedUsers: Children<User,BlockedUser> {
        return children(\.ownerID)
    }
    
    var blockedHosts: Children<User,BlockedHost> {
        return children(\.ownerID)
    }

    var blockedLinks: Children<User,BlockedLink> {
        return children(\.ownerID)
    }

    var reportedLinks: Children<User,ReportedLink> {
        return children(\.ownerID)
    }
}


extension User {
    var subscribedTopics: Siblings<User,Topic,UserTopicPivot> {
        return siblings()
    }
    
    var pinnedReplies: Siblings<User,Reply,UserReplyPivot> {
        return siblings()
    }
}

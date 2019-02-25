//
//  UserController+BlockedUsers.swift
//  App
//
//  Created by Li Fumin on 2019/2/11.
//

import Foundation
import Vapor
import Fluent
import FluentPostgreSQL
import Crypto

extension UserController {

    func getCountsOfBlockedUsers(req: Request) throws -> Future<Int> {
        let userID = try req.parameters.next(Int.self)
        return BlockedUser.query(on: req).filter(\.ownerID == userID).all().map({ list in
            return list.count
        })
    }

    func getBlockedUsers(req: Request) throws -> Future<[BlockedUser]> {
        let userID = try req.parameters.next(Int.self)
        let batch = try req.parameters.next(Int.self)
        let start = 0 + 50*batch
        let end = 50 + 50*batch

        return BlockedUser.query(on: req).filter(\.ownerID == userID).sort(\.createdAt, .descending).range(start..<end).all().flatMap({ bUsers in
            guard bUsers.count != 0 else {
                return req.future(bUsers)
            }

            //批量获取对应的用户，以获取他们的nickname
            var lists = [Future<User?>]()
            bUsers.forEach({ u in
                lists.append(User.find(u.id!, on: req))
            })
            return lists.flatten(on: req).map({ users in
                let fUsers = users.compactMap {$0}
                let fUsersIDs = fUsers.map { $0.id}
                return bUsers.map({ bU in
                    if let index = fUsersIDs.index(of: bU.id) {
                        let userT = fUsers[index]
                        var bUNew = bU
                        bUNew.blockedUserName = userT.nickName ?? userT.email.components(separatedBy: "@").first
                        return bUNew
                    }
                    return bU
                })
            })
        })
    }

    func deleteBlockedUser(req: Request) throws -> Future<HTTPResponseStatus> {
        let id = try req.parameters.next(Int.self)
        return BlockedUser.find(id, on: req).flatMap({ bUser in
            guard let bUserT = bUser else {
                throw Abort(.notFound, reason: "删除条目id无效", identifier: nil)
            }
            return bUserT.delete(on: req).transform(to: .ok)
        })
    }
}

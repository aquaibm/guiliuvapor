//
//  UserController+BlockedHosts.swift
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

    func getCountsOfBlockedHosts(req: Request) throws -> Future<Int> {
        let userID = try req.parameters.next(Int.self)
        return BlockedHost.query(on: req).filter(\.ownerID == userID).all().map({ list in
            return list.count
        })
    }

    func getBlockedHosts(req: Request) throws -> Future<[BlockedHost]> {
        let userID = try req.parameters.next(Int.self)
        let batch = try req.parameters.next(Int.self)
        let start = 0 + 50*batch
        let end = 50 + 50*batch
        return BlockedHost.query(on: req).filter(\.ownerID == userID).sort(\.createdAt, .descending).range(start..<end).all()
    }

    func deleteBlockedHost(req: Request) throws -> Future<HTTPResponseStatus> {
        let id = try req.parameters.next(Int.self)
        return BlockedHost.find(id, on: req).flatMap({ bHost in
            guard let bHostT = bHost else {
                throw Abort(.notFound, reason: "删除条目id无效", identifier: nil)
            }
            return bHostT.delete(on: req).transform(to: .ok)
        })
    }
}

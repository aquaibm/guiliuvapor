//
//  UserController+BlockedLinks.swift
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

    func getCountsOfBlockedLinks(req: Request) throws -> Future<Int> {
        let userID = try req.parameters.next(Int.self)
        return BlockedLink.query(on: req).filter(\.ownerID == userID).all().map({ list in
            return list.count
        })
    }

    func getBlockedLinks(req: Request) throws -> Future<[BlockedLink]> {
        let userID = try req.parameters.next(Int.self)
        let batch = try req.parameters.next(Int.self)
        let start = 0 + 50*batch
        let end = 50 + 50*batch
        return BlockedLink.query(on: req).filter(\.ownerID == userID).sort(\.createdAt, .descending).range(start..<end).all()
    }

    func deleteBlockedLink(req: Request) throws -> Future<HTTPResponseStatus> {
        let id = try req.parameters.next(Int.self)
        return BlockedLink.find(id, on: req).flatMap({ bLink in
            guard let bLinkT = bLink else {
                throw Abort(.notFound, reason: "删除条目id无效", identifier: nil)
            }
            return bLinkT.delete(on: req).transform(to: .ok)
        })
    }
}

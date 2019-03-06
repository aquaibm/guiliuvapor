//
//  TopicController+QueryViaID.swift
//  App
//
//  Created by Li Fumin on 2019/3/6.
//

import Foundation
import Vapor
import Fluent
import FluentPostgreSQL


extension TopicController {
    func getTopicViaID(request: Request) throws -> Future<Topic> {
        let tpID = try request.parameters.next(Int.self)
        return Topic.query(on: request).filter(\.id == tpID).first().map({ tp in
            guard let trueTp = tp else {
                throw Abort(.notFound, reason: "没有对应id为\(tpID)的主题", identifier: nil)
            }

            return trueTp
        })
    }
}

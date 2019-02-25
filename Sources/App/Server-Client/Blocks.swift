//
//  BlockedPair.swift
//  App
//
//  Created by Li Fumin on 2018/8/2.
//

import Foundation
import Vapor

struct Blocks: Content{
    var ownerID: Int
    
    var blockedUserID: Int?
    var blockedHost: String?
    var blockedLink: String?
    var isOffensive: Bool?
}

//
//  UserReplyPair.swift
//  App
//
//  Created by Li Fumin on 2018/7/4.
//

import Foundation
import Vapor

//用户点赞回复关系表
struct UserPinReplyPair: Content {
    var userID: Int
    var replyID: Int
    var interactionType: Int  //1 = like, 2 = dislike, 0 = none
}

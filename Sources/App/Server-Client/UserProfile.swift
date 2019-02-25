//
//  UserProfile.swift
//  App
//
//  Created by Li Fumin on 2018/9/17.
//

import Foundation
import Vapor


struct UserProfile: Content {
    var userID: Int
    var userNickName: String?
    
    var userPWord: String?
    var userNewPWord: String?
}

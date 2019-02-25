//
//  UserCtrller.swift
//  App
//
//  Created by Li Fumin on 2018/6/2.
//

import Foundation
import Vapor
import Fluent
import FluentPostgreSQL
import Crypto

struct UserController {
    //Post
    func userRegistration(request: Request, newUser: User) throws -> Future<HTTPResponseStatus> {
        return User.query(on: request).filter(\.email == newUser.email).first().flatMap({ existingUser in
            guard existingUser == nil else {
                throw Abort(.badRequest, reason: "该邮件地址已被注册使用" , identifier: nil)
            }
            
            let digest = try request.make(BCryptDigest.self)
            let hashedPassword = try digest.hash(newUser.password)
            let persistedUser = User(email: newUser.email, password: hashedPassword)
            return persistedUser.save(on: request).transform(to: .created)
        })
    }
    
    func userLogin(request: Request, user: User) throws -> Future<User> {
        return User.query(on: request).filter(\.email == user.email).first().map({ existingUser in
            guard let existingUser = existingUser else {
                throw Abort(.badRequest, reason: "没有此用户", identifier: nil)
            }
            let digest = try request.make(BCryptDigest.self)
            if try digest.verify(user.password, created: existingUser.password) {
                return existingUser
            }
            else {
                throw Abort(.badRequest, reason: "密码错误", identifier: nil)
            }
        })
    }
    
    func modifyProfile(req: Request, profile: UserProfile) throws -> Future<HTTPResponseStatus> {
        let uid = profile.userID
        return User.find(uid, on: req).flatMap({ existingUser in
            guard var existingUserT = existingUser else {
                throw Abort(.badRequest, reason: "没有此用户", identifier: nil)
            }
            
            //修改昵称
            existingUserT.nickName = profile.userNickName
            
            //需要修改密码吗？
            if let currentPW = profile.userPWord, let newPW = profile.userNewPWord {
                let digest = try req.make(BCryptDigest.self)
                
                if try digest.verify(currentPW, created: existingUserT.password) {
                    //密码校验成功
                    let hashedPassword = try digest.hash(newPW)
                    existingUserT.password = hashedPassword
                }
                else {
                    throw Abort(.badRequest, reason: "密码校验失败", identifier: nil)
                }
            }
            
            return existingUserT.save(on: req).transform(to: .ok)
        })
    }
    
    
    //Get    
    func getUserNickName(request: Request) throws -> Future<String> {
        let userID = try request.parameters.next(Int.self)
        return User.find(userID, on: request).map({ user in
            guard let userT = user else {
                throw Abort(.notFound, reason: "没有此用户", identifier: nil)
            }
            
            return userT.nickName ?? userT.email.components(separatedBy: "@").first ?? ""
        })
    }
}

//
//  CommonTestData.swift
//  GithubUsersTests
//
//  Created by Hasaan Ali on 30/12/2020.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

@testable import GithubUsers
import Foundation
import UIKit

class CommonTestData {
    static let defaultUsers: [User] = {
        var users = [User]()
        for i in 0..<100 {
            users.append(User(id: i, login: "user\(i)login", avatarUrl: "user\(i)avatarurl"))
        }
        return users
    }()

    static let dbUsersTestDataWithoutImages: [UserProtocol] = {
        var users = [UserProtocol]()
        for i in 0..<100{
            switch i%6 {
            case  0:
                users.append(NotesUser(id: i, login: "user\(i)login", avatarUrl: "user\(i)avatarurl", notes: "user\(i)notes"))
            default:
                users.append(User(id: i, login: "user\(i)login", avatarUrl: "user\(i)avatarurl"))
            }
        }
        return users
    }()

    static let image: UIImage = {
        let size = CGSize(width: 10, height: 10)
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            UIColor.blue.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }()

    static let usersWithImages: [UserProtocol] = {
        var users = [UserProtocol]()
        for i in 0..<100{
            switch i%6 {
            case 0:
                users.append(NotesUser(id: i, login: "user\(i)login", avatarUrl: "user\(i)avatarurl", notes: "user\(i)notes", image: image))
            case 1:
                users.append(InvertedUser(
                    id: i,
                    login: "user\(i)login",
                    avatarUrl: "user\(i)avatarurl",
                    image: image,
                    notes: "user\(i)notes"
                ))
            default:
                users.append(User(id: i, login: "user\(i)login", avatarUrl: "user\(i)avatarurl", image: image))
            }
        }
        return users
    }()

    ///Returns tuple (users, missingImageIndices)
    static let dbUsersMissingImagesTestData: ([UserProtocol], [Int]) = {
        var users = [UserProtocol]()
        var missingImageIndices = [Int]()

        var user: UserProtocol
        var id: Int
        for i in 0..<100{
            id = i+201 // some different id possible in real
            switch i%11 {
            case 0:
                user = NotesUser(id: id, login: "user\(i)login", avatarUrl: "user\(i)avatarurl", notes: "user\(i)notes")
                missingImageIndices.append(i)
            case 1:
                user = NotesUser(id: id, login: "user\(i)login", avatarUrl: "user\(i)avatarurl", notes: "user\(i)notes", image: image)
            case 2:
                user = InvertedUser(id: id, login: "user\(i)login", avatarUrl: "user\(i)avatarurl", notes: "user\(i)notes")
                missingImageIndices.append(i)
            case 3:
                user = InvertedUser(id: id, login: "user\(i)login", avatarUrl: "user\(i)avatarurl", image: image, notes: "user\(i)notes")
            case 4:
                user = User(id: id, login: "user\(i)login", avatarUrl: "user\(i)avatarurl")
                missingImageIndices.append(i)
            default:
                user = User(id: id, login: "user\(i)login", avatarUrl: "user\(i)avatarurl", image: image)
            }
            users.append(user)
        }
        return (users, missingImageIndices)
    }()
}

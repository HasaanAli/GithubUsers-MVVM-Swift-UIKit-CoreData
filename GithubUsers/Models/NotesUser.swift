//
//  NotesUser.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/22/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit

struct NotesUser: UserProtocol, Equatable {
    let id: Int
    let login: String
    let avatarUrl: String
    var image: UIImage? // initially nil, will be set outside
    var notes: String // Empty string = No notes, local property, not in Api

    init(id: Int, login: String, avatarUrl: String, notes: String, image: UIImage? = nil) {
        self.id = id
        self.login = login
        self.avatarUrl = avatarUrl
        self.image = image
        self.notes = notes
    }

    init(user: User, withNotes notes: String) {
        self.id = user.id
        self.login = user.login
        self.avatarUrl = user.avatarUrl
        self.image = user.image
        self.notes = notes
    }

    init(notesUser: NotesUser, withNotes notes: String) {
        self.id = notesUser.id
        self.login = notesUser.login
        self.avatarUrl = notesUser.avatarUrl
        self.image = notesUser.image
        self.notes = notes
    }
}

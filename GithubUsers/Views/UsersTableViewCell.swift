//
//  UsersTableViewCell.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/18/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit

class UsersTableViewCell: UITableViewCell {
    static let CellIdentifier = "UsersTableViewCell"

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var noteImageView: UIImageView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!

    override func prepareForReuse() {
        super.prepareForReuse()
        configure(with: .none)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        indicatorView.hidesWhenStopped = true
        indicatorView.color = .purple
    }

    func configure(with user: User?) {
        let dataViews: [UIView] = [profileImageView, usernameLabel, detailsLabel]

        guard let user = user else {
            dataViews.forEach { $0.isHidden = true }
            profileImageView.image = nil // TODO user.avatarUrl
            usernameLabel?.text = ""
            detailsLabel?.text = ""
            noteImageView.isHidden = true
            indicatorView.startAnimating()
            return
        }

        profileImageView.image = user.image
        usernameLabel?.text = user.login
        detailsLabel?.text = "..."
        noteImageView.isHidden = user.notes.isEmpty
        indicatorView.stopAnimating()
        dataViews.forEach { $0.isHidden = false }
    }
}

//
//  NotesUserTableViewCell.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/22/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit

class NotesUserTableViewCell: UITableViewCell, UserTableViewCellProtocol {
    let tag2 = "UsersTableViewCell-" // TODO think of better name other than tag
    static let CellIdentifier = "NotesUserTableViewCell"

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var noteImageView: UIImageView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!

    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func reset() {
        profileImageView.image = nil
        profileImageView.isHidden = true
        usernameLabel?.text = ""
        usernameLabel.isHidden = true
        detailsLabel?.text = ""
        detailsLabel.isHidden = true
        noteImageView.isHidden = true
        indicatorView.stopAnimating()
        indicatorView.hidesWhenStopped = true
    }

    func configure(with userp: UserProtocol) {
        // No need to cast userp as NotesUser as we're not using notes value here.
        if let image = userp.image {
            profileImageView.image = image
            profileImageView.isHidden = false
            indicatorView.stopAnimating()
        } else {
            profileImageView.image = nil
            profileImageView.isHidden = true
            indicatorView.startAnimating()
        }

        usernameLabel?.text = userp.login
        usernameLabel.isHidden = false
        detailsLabel?.text = "..."
        detailsLabel.isHidden = false
        noteImageView.isHidden = false
    }
}


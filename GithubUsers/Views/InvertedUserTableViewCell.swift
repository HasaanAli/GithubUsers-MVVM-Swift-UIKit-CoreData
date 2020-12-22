//
//  InvertedNotesUserTableViewCell.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/22/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit

class InvertedNotesUserTableViewCell: UITableViewCell, UserTableViewCellProtocol {
    let tag2 = "InvertedNotesUserTableViewCell-" // TODO think of better name other than tag
    static let CellIdentifier = "InvertedNotesUserTableViewCell"

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
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
        indicatorView.stopAnimating()
        indicatorView.hidesWhenStopped = true
    }

    func configure(with userp: UserProtocol) {

        if let image = userp.image {
            // Need to cast userp as InvertedUser ONLY for invertedImage
            if let invertedImage = (userp as? InvertedUser)?.invertedImage {
                profileImageView.image = invertedImage
            } else {
                profileImageView.image = image
            }

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
    }
}


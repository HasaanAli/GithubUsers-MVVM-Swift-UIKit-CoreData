//
//  InvertedUserTableViewCell.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/22/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit

class InvertedUserTableViewCell: UITableViewCell, UserTableViewCellProtocol {
    static let CellIdentifier = "InvertedUserTableViewCell"

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var noteImageView: UIImageView!
    
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
        noteImageView.isHidden = true
    }

    func configure(with userp: UserProtocol) {

        guard let invertedUser = userp as? InvertedUser else {
            // Utilize userp as much as possible
            profileImageView.image = userp.image // TODO
            usernameLabel.text = userp.login
            detailsLabel.text = ""
            noteImageView.isHidden = true
            return
        }

        if let image = invertedUser.invertedImage {
            profileImageView.image = image
            profileImageView.isHidden = false
            indicatorView.stopAnimating()
        } else {
            profileImageView.image = nil
            profileImageView.isHidden = true
            indicatorView.startAnimating()
        }

        usernameLabel?.text = invertedUser.login
        usernameLabel.isHidden = false
        detailsLabel?.text = invertedUser.notes
        detailsLabel.isHidden = false
        noteImageView.isHidden = invertedUser.notes.isEmpty
    }
}


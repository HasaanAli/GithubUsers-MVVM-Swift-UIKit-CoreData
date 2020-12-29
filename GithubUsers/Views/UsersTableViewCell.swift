//
//  DefaultUserTableViewCell.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/18/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit

class DefaultUserTableViewCell: UITableViewCell, UserTableViewCellProtocol {
    private let tag2 = "DefaultUserTableViewCell-" // TODO think of better name other than tag
    static let CellIdentifier = "DefaultUserTableViewCell"

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!

    lazy var allViews: [UIView] = {
        return [profileImageView, usernameLabel, detailsLabel, indicatorView]
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func reset() {
        allViews.forEach { $0.isHidden = true }
        profileImageView.image = nil
        usernameLabel?.text = ""
        detailsLabel?.text = ""
        indicatorView.stopAnimating()
        indicatorView.hidesWhenStopped = true
    }

    func configure(with userp: UserProtocol) {
        // No need to cast userp to User
        allViews.forEach { $0.isHidden = false }

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
        detailsLabel?.text = ""
    }
}

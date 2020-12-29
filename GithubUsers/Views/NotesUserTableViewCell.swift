//
//  NotesUserTableViewCell.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/22/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit

class NotesUserTableViewCell: UITableViewCell, UserTableViewCellProtocol {
    private let tag2 = "NotesUserTableViewCell-" // TODO think of better name other than tag
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
        detailsLabel?.text = (userp as? NotesUser)?.notes
        detailsLabel.isHidden = false
        noteImageView.isHidden = false
    }
}

//
////Code UI
//class NotesUserTableViewCell: UITableViewCell, UserTableViewCellProtocol {
//    static let Tag = "NotesUserTableViewCell - "
//    static let CellIdentifier = "NotesUserTableViewCell"
//
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        reset()
//    }
//
//    func reset() {
//        loginLabel.text = ""
//        detailsLabel.text = ""
//        profileImageView.image = nil
//    }
//
//    func configure(with userp: UserProtocol) {
//        guard let notesUser = userp as? NotesUser else {
//            NSLog("%@ configure(with:) - Failed at userp as? NotesUser.", NotesUserTableViewCell.Tag)
//            return
//        }
//        profileImageView.image = notesUser.image
//        loginLabel.text = notesUser.login
//        detailsLabel.text = "..."
//    }
//
//    private let profileImageView : UIImageView = {
//        let imgView = UIImageView(image: nil)
//        imgView.contentMode = .scaleAspectFit
//        imgView.clipsToBounds = true
//        return imgView
//    }()
//
//
//    private let loginLabel : UILabel = {
//        let lbl = UILabel()
//        lbl.textColor = .black
//        lbl.font = UIFont.boldSystemFont(ofSize: 16)
//        lbl.textAlignment = .left
//        return lbl
//    }()
//
//
//    private let detailsLabel : UILabel = {
//        let lbl = UILabel()
//        lbl.textColor = .black
//        lbl.font = UIFont.systemFont(ofSize: 16)
//        lbl.textAlignment = .left
//        lbl.numberOfLines = 0
//        return lbl
//    }()
//
//    private let notesImageView : UIImageView = {
//        let imgView = UIImageView(image: nil)
//        imgView.contentMode = .scaleAspectFit
//        imgView.clipsToBounds = true
//        imgView.backgroundColor = UIColor.cyan
//        return imgView
//    }()
//
//    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        heightAnchor.constraint(equalToConstant: 35)
//        contentView.addSubview(profileImageView)
//        contentView.addSubview(loginLabel)
//        contentView.addSubview(detailsLabel)
//        contentView.addSubview(notesImageView)
//
//        setupConstraints()
//    }
//
//    func setupConstraints() {
//        translatesAutoresizingMaskIntoConstraints = false
//        // Profile Image View
//        profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1).isActive = true
//        profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2).isActive = true
//        profileImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1).isActive = true
//        profileImageView.widthAnchor.constraint(equalTo: profileImageView.heightAnchor, constant: 0).isActive = true // 1:1 aspect ratio
//
//        // Login label
//        loginLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2).isActive = true
//        loginLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 2).isActive = true
//        loginLabel.trailingAnchor.constraint(equalTo: notesImageView.leadingAnchor, constant: -2).isActive = true
//
//        // Details label
//        detailsLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 5).isActive = true
//        detailsLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 2).isActive = true
//        detailsLabel.trailingAnchor.constraint(equalTo: notesImageView.leadingAnchor, constant: -2).isActive = true
//
//        // Notes image view
//        notesImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
//        notesImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2).isActive = true
//        notesImageView.widthAnchor.constraint(equalToConstant: 8).isActive = true
//        notesImageView.heightAnchor.constraint(equalToConstant: 8).isActive = true
//
////
////
////        productImage.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 0, width: 90, height: 0, enableInsets: false)
////        productNameLabel.anchor(top: topAnchor, left: productImage.rightAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: frame.size.width / 2, height: 0, enableInsets: false)
////        productDescriptionLabel.anchor(top: productNameLabel.bottomAnchor, left: productImage.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: frame.size.width / 2, height: 0, enableInsets: false)
////
////
////        let stackView = UIStackView(arrangedSubviews: [decreaseButton,productQuantity,increaseButton])
////        stackView.distribution = .equalSpacing
////        stackView.axis = .horizontal
////        stackView.spacing = 5
////        addSubview(stackView)
////        stackView.anchor(top: topAnchor, left: productNameLabel.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 15, paddingLeft: 5, paddingBottom: 15, paddingRight: 10, width: 0, height: 70, enableInsets: false)
////
////        increaseButton.addTarget(self, action: #selector(increaseFunc), for: .touchUpInside)
////        decreaseButton.addTarget(self, action: #selector(decreaseFunc), for: .touchUpInside)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
////        fatalError("init(coder:) has not been implemented")
//    }
//}


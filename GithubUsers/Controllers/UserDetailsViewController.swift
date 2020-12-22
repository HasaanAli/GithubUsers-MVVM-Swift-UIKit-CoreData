//
//  UserDetailsViewController.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/21/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit

protocol UserDetailsNotesDelegate {
    func onNotesUpdated(notes: String, at indexPath: IndexPath?)
}

class UserDetailsViewController: UIViewController {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followersValueLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followingValueLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var viewModel: UserDetailsViewModel?
    var notesDelegate: UserDetailsNotesDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        bioTextView.layer.borderWidth = 0.5
        bioTextView.layer.borderColor = UIColor.gray.cgColor
        notesTextView.layer.borderWidth = 1
        notesTextView.layer.borderColor = UIColor.gray.cgColor
        profileImageView.image = viewModel?.image
        notesTextView.text = viewModel?.notes
        viewModel?.fetchDetails()
    }
    
    @IBAction func onSave(_ sender: Any) {
        let newNotes = notesTextView.text ?? ""
        viewModel?.save(notes: newNotes)
        navigationController?.popViewController(animated: true)
        notesDelegate?.onNotesUpdated(notes: newNotes, at: viewModel?.indexPath)
    }
}

extension UserDetailsViewController: UserDetailsViewModelDelegate {
    func onDetailsSuccess(userDetails: UserDetails) {

        if let followers = userDetails.followers {
            followersValueLabel.text = "\(followers)"
        } else {
            followersValueLabel.text = "?"
        }

        if let following = userDetails.following {
            followingValueLabel.text = "\(following)"
        } else {
            followingValueLabel.text = "?"
        }

        bioTextView.text = userDetails.bio
        activityIndicator.stopAnimating()
        let hiddenViews: [UIView] = [followingLabel, followingValueLabel, followersLabel, followersValueLabel, bioTextView]
        hiddenViews.forEach { $0.isHidden = false }
    }

    func onDetailsFailed(error: DataResponseError) {
        NSLog("onDetailsFailed - error: %@", error.description)
    }
}

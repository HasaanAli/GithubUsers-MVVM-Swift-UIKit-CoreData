//
//  UserDetailsViewController.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/21/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit

protocol UserDetailsViewControllerDelegate {
    func onNotesUpdated(with notes: String, for cellViewModel: UserCellViewModelProtocol, at visibleIndexPath: IndexPath)
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
    @IBOutlet weak var networkAvailabilityLabel: NetworkAvailabilityView!

    var viewModel: UserDetailsViewModel?
    var delegate: UserDetailsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        bioTextView.layer.borderWidth = 0.5
        bioTextView.layer.borderColor = UIColor.gray.cgColor
        notesTextView.layer.borderWidth = 1
        notesTextView.layer.borderColor = UIColor.gray.cgColor
        networkAvailabilityLabel.isHidden = true
        profileImageView.image = viewModel?.image
        notesTextView.text = viewModel?.notes
        viewModel?.fetchDetails()
        //TODO: Register with Reachability instance
    }
    
    @IBAction func onSave(_ sender: Any) {
        let newNotes = notesTextView.text ?? ""
        viewModel?.save(notes: newNotes)
        networkAvailabilityLabel.showWith(customGoodText: "Notes saved.")
        notesTextView.resignFirstResponder()
    }
}

extension UserDetailsViewController: UserDetailsViewModelDelegate {
    func onLoadDetailsSuccess(userDetails: UserDetails) {
        networkAvailabilityLabel.setFor(networkAvailable: true)
        // don't change isHidden
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

    func onLoadDetailsFailed(error: DataResponseError) {
        switch error {
        case .network:
            networkAvailabilityLabel.setFor(networkAvailable: false)
            networkAvailabilityLabel.isHidden = false
        case .decoding:
            networkAvailabilityLabel.showWith(customBadText: "Details parsing failed. Email at dev@g.com")
        }
        NSLog("onDetailsFailed - error: %@", error.description)
    }

    func onNotesChanged(to notes: String) {
        guard let viewModel = viewModel else {
            NSLog("missing UserDetails viewModel")
            return
        }
        delegate?.onNotesUpdated(with: notes, for: viewModel.tappedCellViewModell, at: viewModel.tappedIndexPath)
    }
}

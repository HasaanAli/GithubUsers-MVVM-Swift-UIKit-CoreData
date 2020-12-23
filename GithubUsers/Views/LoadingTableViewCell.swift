//
//  LoadingTableViewCell.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/21/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {
    static let CellIdentifier = "LoadingTableViewCell"
    var indicatorView: UIActivityIndicatorView? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Initialization code
        let indicatorView = UIActivityIndicatorView(style: .gray)
        self.indicatorView = indicatorView
        indicatorView.color = UIColor.purple
        indicatorView.hidesWhenStopped = true
        indicatorView.startAnimating()
        contentView.addSubview(indicatorView)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        indicatorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NSLog("LoadingTableViewCell required init called")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }
}

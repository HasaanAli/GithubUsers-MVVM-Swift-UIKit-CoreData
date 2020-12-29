//
//  NetworkAvailabilityView.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/22/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit

class NetworkAvailabilityView: UILabel {

    private let networkAvailableText = "Internet is available now."
    private let networkUnavailableText = "Internet is not available.\n Will auto reload when it's back."

    private let availableBGColor = UIColor.green
    private let availableTextColor = UIColor.white

    private let unavailableBGColor = UIColor.red
    private let unavailableTextColor = UIColor.white

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        font = UIFont.systemFont(ofSize: 16)
        isHidden = true
    }

    func setFor(networkAvailable: Bool) {
        if networkAvailable {
            backgroundColor = availableBGColor
            textColor = availableTextColor
            text = networkAvailableText
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                if text == networkAvailableText {
//                    self.isHidden = true
//                }
//            }
        } else {
            backgroundColor = unavailableBGColor
            textColor = unavailableTextColor
            text = networkUnavailableText
        }
    }

    func showWith(customBadText: String) {
        isHidden = false
        backgroundColor = unavailableBGColor
        textColor = unavailableTextColor
        text = customBadText
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.isHidden = true
        }
    }

    func showWith(customGoodText: String) {
        isHidden = false
        backgroundColor = availableBGColor
        textColor = availableTextColor
        text = customGoodText
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isHidden = true
        }
    }
}

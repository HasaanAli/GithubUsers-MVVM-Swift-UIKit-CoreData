//
//  UIImage+jpegDataBetter.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 30/12/2020.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit

extension UIImage {
    /// Compression quality = 0.7
    var jpegDataBetter: Data? {
        return jpegData(compressionQuality: 0.7)
    }
}

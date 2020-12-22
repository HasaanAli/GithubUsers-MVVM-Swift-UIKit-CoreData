//
//  ImageUtilities.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/22/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit

class ImageUtilities {
    /// Returns an inverted color image.
    static func invert(image theImage: UIImage) -> UIImage? {
        guard let filter = CIFilter(name: "CIColorInvert") else {
            NSLog("UsersViewModel - invert(image:) - Failed at creating CIFilter")
            return nil
        }

        filter.setValue(CIImage(image: theImage), forKey: kCIInputImageKey)
        //^this applies our filter to our UIImage

        guard let outputImage = filter.outputImage else {
            NSLog("UsersViewModel - invert(image:) - Failed, got nil at filter.outputImage")
            return nil
        }

        return UIImage(ciImage: outputImage)
        //^ return inverted UIImage
    }
}

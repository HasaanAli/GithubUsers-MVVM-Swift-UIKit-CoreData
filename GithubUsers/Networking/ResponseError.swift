//
//  ResponseError.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/19/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

enum DataResponseError: Error, CustomStringConvertible {
    case network
    case decoding

    var description: String {
        switch self {
        case .network:
            return "An error occurred while fetching data."
        case .decoding:
            return "An error occurred while decoding data."
        }
    }
}

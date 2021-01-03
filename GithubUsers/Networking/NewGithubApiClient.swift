//
//  NewGithubApiClient.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 03/01/2021.
//  Copyright © 2021 Hasaan Ali. All rights reserved.
//

import Foundation
import Combine

class NewGithubApiClient {
    static func fetchUsers(since: Int, perPage: Int) -> AnyPublisher<[User], Error> {// todo
        let url = URL(string: "http://api.github.com/users?since=\(since)&perPage=\(perPage)")!

        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap( { output in
                // TODO handle status guard let httpUrlResponse = response as? Http
                return output.data

            })
            .decode(type: [User].self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
    }
    //, completion: @escaping (Result<[User], DataResponseError>) -> Void)
}

//
//  NetworkMonitor.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/22/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import Network

class NetworkMonitor {

    private init() {    }

    static func create(block: @escaping (NWPath) -> Void) {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = block
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
}


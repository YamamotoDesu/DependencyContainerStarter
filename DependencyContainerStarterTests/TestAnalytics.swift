//
//  TestAnalytics.swift
//  DependencyContainerStarterTests
//
//  Created by Yamamoto Kyo on 2024/05/27.
//

import Foundation

protocol TestAnalyticsProtocol {
    func trackEvent()
}

struct TestAnalytics: TestAnalyticsProtocol {

    private let networking: TestNetworkingProtocol

    init(networking: TestNetworkingProtocol) {
        self.networking = networking
    }

    func trackEvent() {
        networking.makeNetworkRequest()
    }
}

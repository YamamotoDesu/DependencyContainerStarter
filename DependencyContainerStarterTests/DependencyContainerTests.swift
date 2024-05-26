//
//  DependencyContainerTests.swift
//  DependencyContainerTests
//
//  Created by Yamamoto Kyo on 2024/05/26.
//

import XCTest
@testable import DependencyContainerStarter

final class DependencyContainerTests: XCTestCase {

    func test_single_instance_registration() {
        let myInstance = SingleInstanceDependency()
        DependencyContainer.shared.register(type: .singleInstance(myInstance), for: SingleInstanceDependency.self)

        let resolved = DependencyContainer.shared.resolve(type: .singleInstance, for: SingleInstanceDependency.self)

        XCTAssertTrue(myInstance === resolved)
    }

    func test_closure_registration() {
        let myInstanceProvidingClosure: () -> ClosureDependencyPtotocol = {
            ClosureDependency()
        }
        DependencyContainer.shared.register(type: .closureBased(myInstanceProvidingClosure), for: ClosureDependencyPtotocol.self)

        let _ = DependencyContainer.shared.resolve(type: .closureBased, for: ClosureDependencyPtotocol.self)
    }

    func test_resolving_another_dependency_withth_closure_before_returing_from_closure() {
        let networkingInstance = TestNetworking()
        DependencyContainer.shared.register(type: .singleInstance(networkingInstance), for: TestNetworkingProtocol.self)

        let analyticsProvidingClosure: () -> TestAnalyticsProtocol = {
            let networking = DependencyContainer.shared.resolve(type: .singleInstance, for: TestNetworkingProtocol.self)
            return TestAnalytics(networking: networking)
        }
        DependencyContainer.shared.register(type: .closureBased(analyticsProvidingClosure), for: TestAnalyticsProtocol.self)

        let _ = DependencyContainer.shared.resolve(type: .closureBased, for: TestAnalyticsProtocol.self)
    }
}

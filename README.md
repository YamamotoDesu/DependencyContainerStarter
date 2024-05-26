[Swift Dependency Container Series: Part 2 - Implementing a Container](https://www.youtube.com/embed/zyLDyxFdwgE?si=CJHLQpDSZWRwAYG-)

```swift
import Foundation

enum DependencyRegistrationType {
    case singleInstance(AnyObject)
    case closureBased(() -> Any)
}

enum DependencyResolvingType {
    case singleInstance
    case closureBased
}

final class DependencyContainer {

    static let shared = DependencyContainer()

    private var closureBasedDependencies: [ObjectIdentifier: () -> Any] = [:]
    private var singleInstanceDependencies: [ObjectIdentifier: AnyObject] = [:]

    private let dependencyAccessQueue = DispatchQueue(
        label: "com.dependency.container.example.queue",
        attributes: .concurrent
    )

    private init() { }

    func register(type: DependencyRegistrationType, for interface: Any.Type) {
        dependencyAccessQueue.sync(flags: .barrier) {
            switch type {
            case .singleInstance(let instance):
                singleInstanceDependencies[ObjectIdentifier(interface)] = instance
            case .closureBased(let closure):
                closureBasedDependencies[ObjectIdentifier(interface)] = closure
            }
        }
    }

    func resolve<Value>(type: DependencyResolvingType, for interface: Value.Type) -> Value {
        var value: Value!
        dependencyAccessQueue.sync {
            switch type {
            case .singleInstance:
                guard let resolvedSingleInstance = 
                        singleInstanceDependencies[ObjectIdentifier(interface)] as? Value else {
                    fatalError("There was no instance resistered for \(interface)")
                }
                value = resolvedSingleInstance
            case .closureBased:
                guard let resolvedClosureDependency = closureBasedDependencies[ObjectIdentifier(interface)]?() as? Value else {
                    fatalError("There was no instance resistered for \(interface)")
                }
                value = resolvedClosureDependency
            }
        }
        return value
    }
}

```

[Swift Dependency Container Series: Part 3 - Unit Testing](https://www.youtube.com/watch?v=XtdRLyRk00s)

```swift
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

protocol SingleInstanceDependencyProtocol: AnyObject {
    func testSingleInstanceMethod()
}

final class SingleInstanceDependency: SingleInstanceDependencyProtocol {
    func testSingleInstanceMethod() {
        
    }
}

protocol ClosureDependencyPtotocol {
    func testClosureBaseDependencyMethod()
}

struct ClosureDependency: ClosureDependencyPtotocol {
    func testClosureBaseDependencyMethod() {
         
    }
}

protocol TestNetworkingProtocol {
    func makeNetworkRequest()
}

final class TestNetworking: TestNetworkingProtocol {
    func makeNetworkRequest() {

    }

}

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
```



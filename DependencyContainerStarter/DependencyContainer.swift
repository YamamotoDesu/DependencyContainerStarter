//
//  DependencyContainer.swift
//  DependencyContainerStarter
//
//  Created by Yamamoto Kyo on 2024/05/06.
//

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

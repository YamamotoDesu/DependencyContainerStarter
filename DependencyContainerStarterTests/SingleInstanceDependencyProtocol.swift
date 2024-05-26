//
//  SingleInstanceDependencyProtocol.swift
//  DependencyContainerStarterTests
//
//  Created by Yamamoto Kyo on 2024/05/26.
//

import Foundation

protocol SingleInstanceDependencyProtocol: AnyObject {
    func testSingleInstanceMethod()
}

final class SingleInstanceDependency: SingleInstanceDependencyProtocol {
    func testSingleInstanceMethod() {
        
    }
}

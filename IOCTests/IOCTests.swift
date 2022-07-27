//
//  IOCTests.swift
//  IOCTests
//
//  Created by Claudio Carnino on 27/07/2022.
//

import XCTest
@testable import IOC

class IOCTests: XCTestCase {
    
    var container: DependenciesContainer!

    override func setUp() {
        container = DependenciesContainer()
    }
    
    // MARK: - Basic registering and resolving
    
    func testThatHavingRegisteredADependency_WhenResolvingIt_ThenAnInstanceIsCreated() throws {
        // Given
        container.register(NetworkClient.self) { NetworkClientImpl() }
        // When
        let dependency = container.resolve(NetworkClient.self)
        // Then
        XCTAssertNotNil(dependency as? NetworkClientImpl)
    }
    
    func testThatHavingRegisteredADependency_WhenResolvingItMultipleTimes_ThenMultipleInstancesAreCreated() throws {
        // Given
        container.register(NetworkClient.self) { NetworkClientImpl() }
        // When
        let alpha = container.resolve(NetworkClient.self)
        let beta = container.resolve(NetworkClient.self)
        // Then
        XCTAssertNotIdentical(alpha, beta)
    }
    
    // MARK: - Singleton registering and resolving
    
    func testThatHavingRegisteredASingletonDependency_WhenResolvingIt_ThenAnInstanceIsCreated() throws {
        // Given
        container.registerAsSingleton(NetworkClient.self) { NetworkClientImpl() }
        // When
        let dependency = container.resolve(NetworkClient.self)
        // Then
        XCTAssertNotNil(dependency as? NetworkClientImpl)
    }
    
    func testThatHavingRegisteredASingletonDependency_WhenResolvingItMultipleTimes_ThenSameInstanceIsReturned() throws {
        // Given
        container.registerAsSingleton(NetworkClient.self) { NetworkClientImpl() }
        // When
        let alpha = container.resolve(NetworkClient.self)
        let beta = container.resolve(NetworkClient.self)
        // Then
        XCTAssertIdentical(alpha, beta)
    }
    
    // MARK: - Circular dependencies resolution
    
    func testThatHavingRegisteredMultipleCircularDependencies_WhenResolvingAndUsingThem_ThenResolversWorks() throws {
        // Given
        container.registerAsSingleton(BlueService.self) {
            BlueServiceImpl(redServiceResolver: { self.container.resolve(RedService.self) })
        }
        container.registerAsSingleton(RedService.self) {
            RedServiceImpl(blueServiceResolver: { self.container.resolve(BlueService.self) })
        }
        // When
        let redService = container.resolve(RedService.self)
        let blueService = container.resolve(BlueService.self)
        // Then
        XCTAssertEqual(redService.info, "This service name is Ronny. Other service name is Bronco.")
        XCTAssertEqual(blueService.info, "This service name is Bronco. Other service name is Ronny.")
    }

}

// MARK: - Generic mocks

protocol NetworkClient: AnyObject {
    func get(endpoint: String)
}

class NetworkClientImpl: NetworkClient {
    func get(endpoint: String) {}
}

// MARK: - Circular dependencies mocks

protocol BlueService {
    var name: String { get }
    var info: String { get }
}

protocol RedService {
    var name: String { get }
    var info: String { get }
}

class BlueServiceImpl: BlueService {
    let name = "Bronco"
    let redServiceResolver: () -> RedService
    init(redServiceResolver: @escaping () -> RedService) {
        self.redServiceResolver = redServiceResolver
    }
    var info: String { "This service name is \(name). Other service name is \(redServiceResolver().name)." }
}

class RedServiceImpl: RedService {
    let name = "Ronny"
    let blueServiceResolver: () -> BlueService
    init(blueServiceResolver: @escaping () -> BlueService) {
        self.blueServiceResolver = blueServiceResolver
    }
    var info: String { "This service name is \(name). Other service name is \(blueServiceResolver().name)." }
}

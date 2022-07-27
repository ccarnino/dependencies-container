//
//  DependenciesContainer.swift
//  IOC
//
//  Created by Claudio Carnino on 27/07/2022.
//

import Foundation

public final class DependenciesContainer {
    
    private var factories = [String: Any]()
    private var singletons = [String: Any]()
    
    public init() {}
    
    public func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = "\(type.self)"
        factories[key] = factory
    }
    
    public func registerAsSingleton<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = "\(type.self)"
        factories[key] = { [weak self] () -> T in
            // Return the dependency if already instantiated
            if let instance = self?.singletons[key] as? T {
                return instance
            }
            // Otherwise, instantiate the dependency, keep a reference and return it
            let instance = factory()
            self?.singletons[key] = instance
            return instance
        }
    }
    
    public func resolve<T>(_ type: T.Type) -> T {
        let key = "\(type.self)"
        guard let factory = factories[key],
              let typedFactory = factory as? () -> T else {
            fatalError("Failed to fetch the dependency. This should be catched in development time")
        }
        return typedFactory()
    }
    
}

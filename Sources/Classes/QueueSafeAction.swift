//
//  QueueSafeAction.swift
//  QueueSafeValue
//
//  Created by Vasily on 6/30/20.
//

import Foundation

public struct QueueSafeAction<T> {
    private weak var valueContainer: ValueContainer<T>?
    private weak var accessQueue: DispatchQueue?

    public init (valueContainer: ValueContainer<T>, accessQueue: DispatchQueue) {
        self.valueContainer = valueContainer
        self.accessQueue = accessQueue
    }
    
    public func get() -> T? {
        guard let accessQueue = accessQueue, let valueContainer = valueContainer else { return nil }
        var value: T?
        accessQueue.sync { value = valueContainer.value }
        return value
    }
    
    public func set(value: T) {
        guard let accessQueue = accessQueue, let valueContainer = valueContainer else { return }
        accessQueue.sync { valueContainer.value = value }
    }
    
    public func update(closure: ((_ currentValue: inout T) -> Void)?) {
        guard let accessQueue = accessQueue, let valueContainer = valueContainer else { return }
        accessQueue.sync { closure?(&valueContainer.value) }
    }
    
    public func setNewValueAndReturnOld(new value: T) -> T? {
        guard let accessQueue = accessQueue, let valueContainer = valueContainer else { return nil }
        var currentValue: T?
        accessQueue.sync {
            currentValue = valueContainer.value
            valueContainer.value = value
        }
        return currentValue
    }
}

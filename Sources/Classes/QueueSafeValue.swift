//
//  QueueSafeValue.swift
//  QueueSafeValue
//
//  Created by Vasily on 6/30/20.
//

import Foundation


public class QueueSafeValue<T> {
    private let valueContainer: ValueContainer<T>
    public init (value: T) { valueContainer = ValueContainer(value: value) }
    public var wait: QueueSafeAction.When<T> { .init(valueContainer: valueContainer) }
}

extension QueueSafeValue where T: AnyObject {
    public func getRetainCount() -> CFIndex { valueContainer.getRetainCount() }
}

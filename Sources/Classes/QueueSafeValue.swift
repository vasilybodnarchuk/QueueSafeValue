//
//  QueueSafeValue.swift
//  QueueSafeValue
//
//  Created by Vasily on 6/30/20.
//

import Foundation

public class ValueContainer<T> {
    var value: T
    init (value: T) { self.value = value }
}

public class QueueSafeValue<T> {

    private let valueContainer: ValueContainer<T>!
    private var accessQueue: DispatchQueue!

    public init (value: T) {
        valueContainer = ValueContainer(value: value)
        let address = Unmanaged.passUnretained(self).toOpaque()
        let label = "accessQueue.\(type(of: self)).\(address)"
        accessQueue = DispatchQueue(label: label)
    }

    public var syncInCurrentQueue: QueueSafeAction<T> { .init(valueContainer: valueContainer, accessQueue: accessQueue) }
}

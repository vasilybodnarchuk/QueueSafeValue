//
//  QueueSafeAsyncedValueSpec.swift
//  QueueSafeValue_Tests
//
//  Created by Vasily Bodnarchuk on 9/21/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import QueueSafeValue

class QueueSafeAsyncedValueSpec: QuickSpec, SpecableAsyncedCommands {
    typealias Value = SimpleClass
    typealias Commands = AsyncedCommandsWithPriority<Value>
    typealias QueueSafeValueType = QueueSafeAsyncedValue<Value>

    let queueSafeValueDispatchQueue = Queues.random
    var testedObjectName: String { "Queue Safe Asynced Value Commands" }
    func commands(from queueSafeValue: QueueSafeValueType) -> Commands { queueSafeValue.lowestPriority }
    func createQueueSafeValue(value: SimpleClass) -> QueueSafeValueType { .init(value: value, queue: queueSafeValueDispatchQueue) }
    
    override func spec() { runTests() }
}

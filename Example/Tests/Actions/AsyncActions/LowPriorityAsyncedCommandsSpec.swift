//
//  LowPriorityAsyncedCommandsSpec.swift
//  QueueSafeValue_Tests
//
//  Created by Vasily Bodnarchuk on 8/25/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import QueueSafeValue

class LowPriorityAsyncedCommandsSpec: QuickSpec, SpecableAsyncedCommands {

    typealias Value = SimpleClass
    typealias Commands = AsyncedCommandsWithPriority<Value>
    typealias QueueSafeValueType = QueueSafeValue<Value>
    let queueSafeValueDispatchQueue = Queues.random

    var testedObjectName: String { "Low Priority Asynced Commands" }
    
    func commands(from queueSafeValue: QueueSafeValueType) -> Commands {
        queueSafeValue.async(performIn: queueSafeValueDispatchQueue).lowestPriority
    }

    override func spec() { runTests() }
    func createQueueSafeValue(value: SimpleClass) -> QueueSafeValueType { QueueSafeValue(value: value) }
}

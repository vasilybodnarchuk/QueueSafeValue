//
//  HighestPriorityAsyncedCommandsSpec.swift
//  QueueSafeValue_Tests
//
//  Created by Vasily Bodnarchuk on 9/30/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import QueueSafeValue

class HighestPriorityAsyncedCommandsSpec: QuickSpec, SpecableAsyncedCommands {

    typealias Value = SimpleClass
    typealias Commands = AsyncedCommandsWithPriority<Value>
    typealias QueueSafeValueType = QueueSafeValue<Value>
    let queueSafeValueDispatchQueue = Queues.random

    var testedObjectName: String { "Highest Priority Asynced Commands" }
    
    func commands(from queueSafeValue: QueueSafeValueType) -> Commands {
        queueSafeValue.async(performIn: queueSafeValueDispatchQueue).highestPriority
    }

    override func spec() { runTests() }
    func createQueueSafeValue(value: SimpleClass) -> QueueSafeValueType { QueueSafeValue(value: value) }
}


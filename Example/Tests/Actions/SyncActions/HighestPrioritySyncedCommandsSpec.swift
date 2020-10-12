//
//  HighestPrioritySyncedCommandsSpec.swift
//  QueueSafeValue_Tests
//
//  Created by Vasily Bodnarchuk on 9/30/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import QueueSafeValue

class HighestPrioritySyncedCommandsSpec: QuickSpec, SpecableSyncedCommands {

    typealias Value = SimpleClass
    typealias Commands = SyncedCommandsWithPriority<Value>
    typealias QueueSafeValueType = QueueSafeValue<Value>

    var testedObjectName: String { "Highest Priority Synced Commands" }
    func commands(from queueSafeValue: QueueSafeValueType) -> Commands {
        queueSafeValue.wait.highestPriority
    }
    
    override func spec() { runTests() }
    func createQueueSafeValue(value: SimpleClass) -> QueueSafeValueType { QueueSafeValue(value: value) }
}


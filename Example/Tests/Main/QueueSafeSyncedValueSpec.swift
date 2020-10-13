//
//  QueueSafeSyncedValueSpec.swift.swift
//  QueueSafeValue_Tests
//
//  Created by Vasily Bodnarchuk on 9/17/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import QueueSafeValue

class QueueSafeSyncedValueSpec: QuickSpec, SpecableSyncedCommands {
    typealias Value = SimpleClass
    typealias Commands = SyncedCommandsWithPriority<Value>
    typealias QueueSafeValueType = QueueSafeSyncedValue<Value>

    var testedObjectName: String { "Queue Safe Synced Value Commands" }
    func commands(from queueSafeValue: QueueSafeValueType) -> Commands { queueSafeValue.lowestPriority }
    func createQueueSafeValue(value: SimpleClass) -> QueueSafeValueType { .init(value: value) }
    
    override func spec() { runTests() }
}

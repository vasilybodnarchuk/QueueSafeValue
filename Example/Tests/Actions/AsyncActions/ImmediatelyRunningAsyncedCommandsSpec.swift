//
//  ImmediatelyRunningAsyncedCommandsSpec.swift
//  QueueSafeValue_Tests
//
//  Created by Vasily Bodnarchuk on 9/1/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import QueueSafeValue

class ImmediatelyRunningAsyncedCommandsSpec: QuickSpec, SpecableAsyncedCommands {
    var testedObjectName: String { "Immediately Running Asynced Commands" }
    func commands(from queueSafeValue: QueueSafeValue<Value>, queue: DispatchQueue) -> Commands {
        queueSafeValue.async(performIn: queue).immediately
    }

    override func spec() { runTests() }
}


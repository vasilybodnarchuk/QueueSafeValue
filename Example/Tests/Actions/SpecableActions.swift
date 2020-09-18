//
//  SpecableCommands.swift
//  QueueSafeValue_Tests
//
//  Created by Vasily Bodnarchuk on 8/25/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import QueueSafeValue

protocol SpecableCommands: class {
    associatedtype Value: AnyObject
    associatedtype Commands: AnyObject
    associatedtype QueueSafeValueType

    var testedObjectName: String { get }

    func createQueueSafeValue(value: Value) -> QueueSafeValueType
    func createInstance(value: Int) -> Value

    func commands(from queueSafeValue: QueueSafeValueType) -> Commands
}

extension SpecableCommands {
    func createDefultInstance() -> Value { createInstance(value: 0) }
}

extension SpecableCommands where Value == SimpleClass   {
    func createInstance(value: Int) -> SimpleClass { .init(value: value) }
}

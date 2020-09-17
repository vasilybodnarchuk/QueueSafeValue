//
//  Command.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 9/2/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

/// A `command` that will be executed in `Command Queue` in correct order.
public class Command {

    /// Type of `Closure` to be executed.
    public typealias Closure = () -> Void

    /**
     A number that describes when `command` will be performed.
     The `CommandQueue` will decide whether `priority = 0` (or lowest priority) will be executed first or last.
    */
    public let prioriy: Int

    /// `Closure` to be executed.
    let closure: Closure

    /**
     Initialize object with properties.
     - Parameters:
        - prioriy: A number that describes when `command` will be performed.
        - closure: `Closure`  to be executed.
     - Returns: A `command` that will be executed in `Command Queue` in correct order.
     */

    init(prioriy: Int, closure: @escaping Closure) {
        self.closure = closure
        self.prioriy = prioriy
    }
}

// MARK: Comparable
extension Command: Comparable {
    public static func < (lhs: Command, rhs: Command) -> Bool { lhs.prioriy < rhs.prioriy }
    public static func == (lhs: Command, rhs: Command) -> Bool { lhs.prioriy == rhs.prioriy }
}

// MARK: CustomStringConvertible
extension Command: CustomStringConvertible {
    public var description: String { "Command(priority: \(prioriy))" }
}

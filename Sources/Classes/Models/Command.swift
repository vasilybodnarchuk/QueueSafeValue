//
//  Command.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 9/2/20.
//

import Foundation

public class Command {
    public typealias Closure = () -> Void
    public let prioriy: Int
    let closure: Closure
    init(prioriy: Int, closure: @escaping Closure) {
        self.closure = closure
        self.prioriy = prioriy
    }
}

extension Command: Comparable {
    public static func < (lhs: Command, rhs: Command) -> Bool {
        lhs.prioriy < rhs.prioriy
    }

    public static func == (lhs: Command, rhs: Command) -> Bool {
        lhs.prioriy == rhs.prioriy
    }
}

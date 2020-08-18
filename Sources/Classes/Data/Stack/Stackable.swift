//
//  Stackable.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/18/20.
//

import Foundation

protocol Stackable {
    associatedtype Element
    var isEmpty: Bool { get }
    func peek() -> Element?
    mutating func push(_ element: Element)
    @discardableResult mutating func pop() -> Element?
}

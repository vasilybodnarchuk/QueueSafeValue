//
//  Stackable.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/18/20.
//

import Foundation

protocol Stackable {
    associatedtype Element
    
    /**
     Checks if the stack is empty.
     - Returns: An element to be pushed onto a stack.
     */
    var isEmpty: Bool { get }
    
    /**
     Looks at the top `element` on the stack.
     - Returns: An `element` at the top of a stack.
     */
    func peek() -> Element?
    
    /// Adds (appends) an `element` to a stack.
    func push(_ element: Element)
    
    /**
     Get the first added `element` from a stack.
     - Warning: An element to be returned will be removed from a stack.
     - Returns: The first added `element` from a stack.
     */
    @discardableResult func pop() -> Element?
}

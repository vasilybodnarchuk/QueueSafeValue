//
//  QueueSafeStack.swift
//  Pods
//
//  Created by Vasily Bodnarchuk on 8/3/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation


/// A queue safe (thread safe) stack (`storage`)
public class QueueSafeStack<Element>: Stackable {
    
    /// Queue providing synchronous read / write to storage.
    private let accessQueue: DispatchQueue!
    
    /// Collection of elements.
    private var storage: [Element]
    
    /**
     Initialize object with properties.
     - Returns: A queue safe stack.
     */
    public init() {
        accessQueue = DispatchQueue.createSerialAccessQueue()
        storage = [Element]()
    }
    
    /**
     Checks if the stack is empty.
     - Important: Blocks a queue where this code runs until it completed.
     - Returns: An element to be pushed onto a stack.
     */
    public var isEmpty: Bool {
        var _isEmpty: Bool!
        accessQueue.sync { _isEmpty = storage.isEmpty }
        return _isEmpty
    }
    
    /**
     Looks at the top `element` on the stack.
     - Important: Blocks a queue where this code runs until it completed.
     - Returns: An `element` at the top of a stack.
     */
    public func peek() -> Element? {
        var element: Element?
        accessQueue.sync { element = storage.first }
        return element
    }
    
    /**
     Adds (appends) an `element` to a stack.
     - Important: Blocks a queue where this code runs until it completed.
     - Parameter element: An element to be pushed onto a stack.
     */
    public func push(_ element: Element) { accessQueue.sync { storage.insert(element, at: 0) } }
    
    /**
     Get the first added `element` from a stack.
     - Important: Blocks a queue where this code runs until it completed.
     - Warning: An element to be returned will be removed from a stack.
     - Returns: The first added `element` from a stack.
     */
    public func pop() -> Element? {
        var element: Element?
        accessQueue.sync { element = storage.popLast() }
        return element
    }
}

extension QueueSafeStack: CustomStringConvertible {
    public var description: String { "\(storage)" }
}

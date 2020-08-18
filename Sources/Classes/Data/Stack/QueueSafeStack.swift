//
//  QueueSafeStack.swift
//  Pods
//
//  Created by Vasily Bodnarchuk on 8/3/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

struct QueueSafeStack<Element>: Stackable {
    private let accessQueue: DispatchQueue!
    private var storage: [Element]

    init() {
        accessQueue = DispatchQueue.createSerialAccessQueue()
        storage = [Element]()
    }
    
    var isEmpty: Bool {
        var _isEmpty: Bool!
        accessQueue.sync { _isEmpty = storage.isEmpty }
        return _isEmpty
    }
    
    func peek() -> Element? {
        var element: Element?
        accessQueue.sync { element = storage.first }
        return element
    }

    mutating func push(_ element: Element) { accessQueue.sync { storage.insert(element, at: 0) } }
    mutating func pop() -> Element? {
        var element: Element?
        accessQueue.sync { element = storage.popLast() }
        return element
    }
}

extension QueueSafeStack: CustomStringConvertible { var description: String { "\(storage)" } }

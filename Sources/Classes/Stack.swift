//
//  Stack.swift
//  Pods
//
//  Created by Vasily on 8/3/20.
//

import Foundation

protocol Stackable {
    associatedtype Element
    func peek() -> Element?
    mutating func push(_ element: Element)
    @discardableResult mutating func pop() -> Element?
}

struct Stack<Element>: Stackable /* where Element: Equatable*/ {
    private let accessQueue: DispatchQueue!
    private var storage: [Element]

    init() {
        let label = "accessQueue.\(type(of: self)).\(Date().timeIntervalSince1970)"
        accessQueue = DispatchQueue(label: label,
                                    qos: .unspecified,
                                    attributes: [],
                                    autoreleaseFrequency: .inherit,
                                    target: nil)
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

extension Stack: CustomStringConvertible {
    var description: String { "\(storage)" }
}

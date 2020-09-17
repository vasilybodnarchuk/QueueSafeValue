//
//  PriorityQueue.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 9/2/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

public
struct PriorityQueue<Element> where Element: Comparable {
    // elements - collection where heap store values
    public private(set) var elements = [Element]()
    // priority - description of order in a heap
    let priority: Priority
    public init(priority: Priority) { self.priority = priority }

    public enum Priority {
        case parentsGreaterThanOrEqualChildren
        case parentsLessThanOrEqualChildren

        func isCorrect(parentValue: Element, childValue: Element) -> Bool {
            switch self {
            case .parentsGreaterThanOrEqualChildren: return parentValue >= childValue
            case .parentsLessThanOrEqualChildren: return parentValue <= childValue
            }
        }
    }
}

// MARK: Init

extension PriorityQueue {

    // Init heap from representing array means that array is already ordered to be as base of heap.
    // If not - heap will be not created
    public init?(fromRepresenting array: [Element], priority: Priority) {
        self.init(priority: priority)
        elements = array
        if array.count > 1 {
            var index: Int!
            var indicesQueue = [0]
            indicesQueue.reserveCapacity(indicesQueue.count/2)
            while !indicesQueue.isEmpty {
                index = indicesQueue.popLast()
                let childrenIndices = self.childrenIndices(ofParentAt: index)
                if let childIndex = childrenIndices.left {
                    guard isPriorityCorrect(parentIndex: index, childIndex: childIndex) else { return nil }
                    indicesQueue.insert(childIndex, at: 0)
                }
                if let childIndex = childrenIndices.right {
                    guard isPriorityCorrect(parentIndex: index, childIndex: childIndex) else { return nil }
                    indicesQueue.insert(childIndex, at: 0)
                }
            }
            index += 1
        }
    }

    // Init heap by inserting elements from array means that elements in array will be reordered if needed
    public init(insertElementsFrom array: [Element], priority: Priority) {
        self.init(priority: priority)
        if array.isEmpty { return }
        elements = array
        for index in stride(from: count/2, through: 0, by: -1) {
            siftDown(startAt: index)
        }
    }

    // Check if the priority of the parent element higher than child element
    private func isPriorityCorrect (parentIndex: Int, childIndex: Int) -> Bool {
        priority.isCorrect(parentValue: elements[parentIndex], childValue: elements[childIndex])
    }

    private func isPriorityCorrect (parentValue: Element, childValue: Element) -> Bool {
        priority.isCorrect(parentValue: parentValue, childValue: childValue)
    }
}

// MARK: States

extension PriorityQueue {
    // Get flag that heap is empty (has no values)
    public var isEmpty: Bool { elements.isEmpty }
     // Get number of elements in heap
    public var count: Int { elements.count }
     // Show element with max priority (first that will be removed)
    public func peek() -> Element? { elements.first }
}

// MARK: Get index

extension PriorityQueue {
    // calculated property returns value(s) that do not check bounds of existing heap's collection (elements)
    private func calculateParentIndex(childAt index: Int) -> Int { (index - 1) / 2 }
    private func calculateChildrenIndices(ofParentAt index: Int) -> (left: Int, right: Int) {
        let left = index * 2 + 1
        return (left, left + 1)
    }

    // Check if range 0..<elements.count contains index
    private func isValid(index: Int) -> Bool { 0 ..< count ~= index }

    // Get parent's left and right indices. left and left indices can be nil (do not exist in current heap)
    public func childrenIndices(ofParentAt index: Int) -> (left: Int?, right: Int?) {
        let indices = calculateChildrenIndices(ofParentAt: index)
        return (isValid(index: indices.left) ? indices.left : nil,
                isValid(index: indices.right) ? indices.right : nil)
    }

    // Get the parent index of the child
    public func parentIndex(childAt index: Int) -> Int? {
        let index = calculateParentIndex(childAt: index)
        if isValid(index: index) { return index }
        return nil
    }
}

// MARK: Sift - Reordering mechanism.
// Heap order - where each parent node has higher priority than the child nodes.

extension PriorityQueue {
    // Traverse binary tree from parent node (index) to each child node.
    // Swap elements if needed to order in heap.
    private mutating func siftDown(startAt index: Int, stopAt count: Int? = nil) {
        let count = count ?? self.count
        var parentIndex = index
        var childrenIndices: (left: Int, right: Int)
        var swapDestinationIndex = index
        while true {
            childrenIndices = self.calculateChildrenIndices(ofParentAt: parentIndex)
            swapDestinationIndex = parentIndex
            if  childrenIndices.left < count &&
                isPriorityCorrect(parentIndex: childrenIndices.left, childIndex: parentIndex) {
                    swapDestinationIndex = childrenIndices.left
            }

            if  childrenIndices.right < count &&
                isPriorityCorrect(parentIndex: childrenIndices.right, childIndex: swapDestinationIndex) {
                    swapDestinationIndex = childrenIndices.right
            }

            guard parentIndex != swapDestinationIndex else { return }
            elements.swapAt(parentIndex, swapDestinationIndex)
            parentIndex = swapDestinationIndex
        }
    }

    // Traverse binary tree from child node (index) to the head node of the tree.
    // Swap elements if needed to order in heap.
    private mutating func siftUp(startAt firstIndex: Int) {
        var child = firstIndex
        var parent = calculateParentIndex(childAt: firstIndex)
        while child > 0 && isPriorityCorrect(parentIndex: child, childIndex: parent) {
            elements.swapAt(child, parent)
            child = parent
            parent = calculateParentIndex(childAt: child)
        }
    }
}

// MARK: Insert/Remove

extension PriorityQueue {
    // Insert new element in heap in correct position
    public mutating func insert(_ value: Element) {
        elements.append(value)
        siftUp(startAt: count - 1)
    }

    // Remove element with max priority (first in array "elements") and restore order (swap elements) if needed
    @discardableResult
    public mutating func removeElementWithHighestPriority() -> Element? {
        switch count {
        case 0: return nil
        case 1: return elements.removeLast()
        default:
            elements.swapAt(0, count - 1)
            defer { siftDown(startAt: 0) }
            return elements.removeLast()
        }
    }

    // Remove element with min priority (first in array "elements") and restore order (swap elements) if needed
     @discardableResult
     public mutating func removeElementWithLowestPriority() -> Element? {
         switch count {
         case 0: return nil
         default: return elements.removeLast()
         }
     }

    // Remove element at specific index and restore order (swap elements) if needed
    @discardableResult
    public mutating func remove(at index: Int) -> Element? {
        guard isValid(index: index) else { return nil }
        if index == count - 1 { return elements.removeLast() }
        elements.swapAt(index, count-1)
        defer {
            siftDown(startAt: index)
            siftUp(startAt: index)
        }
        return elements.removeLast()
    }
}

// MARK: Exporting

extension PriorityQueue {
    public func representAsReversedSortedArray() -> [Element] {
        var heap = self
        for index in heap.elements.indices.reversed() {
            heap.elements.swapAt(0, index)
            heap.siftDown(startAt: 0, stopAt: index)
        }
        return heap.elements
    }
}

// MARK: Search

extension PriorityQueue {
    // Get first index of the element
    public func firstIndex(of element: Element, startAt index: Int = 0) -> Int? {
        guard   isValid(index: index),
                isPriorityCorrect(parentValue: elements[index], childValue: element) else { return nil }
        if elements[index] == element { return index }
        let childrenIndices = self.calculateChildrenIndices(ofParentAt: index)
        let left = firstIndex(of: element, startAt: childrenIndices.left)
        let right = firstIndex(of: element, startAt: childrenIndices.right)
        if let left = left, let right = right {return min(left, right) }
        return left ?? right
    }
}

// MARK: CustomStringConvertible & Debug info

extension PriorityQueue: CustomStringConvertible {
    public var description: String { "\(elements)" }

    // Get binary tree representation of the heap. Helpful for debugging
    public func getDiagram() -> String { diagram(forElementAt: 0) }
    private func diagramSpacing() -> String { "  " }
    private func diagram(forElementAt index: Int?,
                         _ top: String = " ",
                         _ root: String = " ",
                         _ bottom: String = " ") -> String {
        guard let index = index else { return "" }
        let childrenIndices = self.childrenIndices(ofParentAt: index)

        if childrenIndices.left == nil && childrenIndices.right == nil {
            return root + " \(elements[index])\n"
        }

        var parentValueString: String!
        if root == " " {
            parentValueString = root + "\(elements[index])\n"
        } else {
            parentValueString = root + " \(elements[index])\n"
        }

        return  diagram(forElementAt: childrenIndices.right,
                        top + "   ",
                        top + "┌─",
                        top + "│  ") +
                parentValueString +
                diagram(forElementAt: childrenIndices.left,
                        bottom + "│  ",
                        bottom + "└─",
                        bottom + "   ")
    }
}

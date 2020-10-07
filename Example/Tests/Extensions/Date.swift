//
//  Date.swift
//  QueueSafeValue_Example
//
//  Created by Vasily Bodnarchuk on 10/7/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}

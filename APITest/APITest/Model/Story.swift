//
//  Story.swift
//  APITest
//
//  Created by 양승현 on 2023/01/04.
//

import Foundation

public struct Story: Codable {
    public let id: Int
    public let title: String
    public let by: String
    public let time: TimeInterval
    public let url: String
}

extension Story: Comparable {
    public static func < (lhs: Story, rhs: Story) -> Bool {
        return lhs.time > rhs.time
    }
}

extension Story: CustomStringConvertible {
    public var description: String {
        return "\n\(title)\nby \(by)\n\(url)\n-----"
    }
}

//
//  Paranoia.swift
//  ParanoiaList
//
//  Created by Yu Liang on 6/21/25.
//

import Foundation

enum ParanoiaStatus: String, Codable {
    case unchecked
    case checked
}

struct ParanoiaItem: Identifiable, Codable {
    let id: UUID
    let title: String
    var status: ParanoiaStatus
    var lastChecked: Date?

    init(id: UUID = UUID(), title: String, status: ParanoiaStatus = .unchecked, lastChecked: Date? = nil) {
        self.id = id
        self.title = title
        self.status = status
        self.lastChecked = lastChecked
    }
}

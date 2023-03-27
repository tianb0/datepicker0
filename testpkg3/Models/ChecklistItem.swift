//
//  ChecklistItem.swift
//  testpkg3
//
//  Created by Tianbo Qiu on 3/27/23.
//

import Foundation

class ChecklistItem: Hashable, Equatable {
    var id: UUID
    var title: String
    var date: Date
    var completed: Bool
    
    init(title: String, date: Date, completed: Bool = false) {
        self.id = UUID()
        self.title = title
        self.date = date
        self.completed = completed
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: ChecklistItem, rhs: ChecklistItem) -> Bool {
        lhs.id == rhs.id
    }
}

extension ChecklistItem {
    
    static var exampleItems: [ChecklistItem] = [
        ChecklistItem(title: "test pkg", date: Date())
    ]
}

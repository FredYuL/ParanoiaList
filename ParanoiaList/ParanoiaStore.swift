//
//  ParanoiaStore.swift
//  ParanoiaList
//
//  Created by Yu Liang on 6/21/25.
//
import Foundation

class ParanoiaStore: ObservableObject {
    @Published var items: [ParanoiaItem] = []

    private let storageKey = "paranoia_items"

    init() {
        load()
        if items.isEmpty {
            items = defaultItems()
        }
    }

    func toggleStatus(for item: ParanoiaItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        var updated = items[index]
        
        // 简单切换状态: unchecked <-> checked
        if updated.status == .unchecked {
            updated.status = .checked
            updated.lastChecked = Date()
        } else {
            updated.status = .unchecked
            updated.lastChecked = nil
        }
        
        items[index] = updated
        save()
    }
    
    func resetAllItems() {
        for index in items.indices {
            items[index].status = .unchecked
            items[index].lastChecked = nil
        }
        save()
    }
    
    func getStats() -> (checked: Int, unchecked: Int) {
        let checked = items.filter { $0.status == .checked }.count
        let unchecked = items.filter { $0.status == .unchecked }.count
        return (checked, unchecked)
    }

    func addItem(title: String) {
        let newItem = ParanoiaItem(title: title)
        items.append(newItem)
        save()
    }
    
    func removeItem(_ item: ParanoiaItem) {
        items.removeAll { $0.id == item.id }
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let savedItems = try? JSONDecoder().decode([ParanoiaItem].self, from: data) else { return }
        self.items = savedItems
    }

    private func defaultItems() -> [ParanoiaItem] {
        return [
            ParanoiaItem(title: "Did I lock the door?"),
            ParanoiaItem(title: "Did I turn off the stove?"),
            ParanoiaItem(title: "Did I lock the car?"),
            ParanoiaItem(title: "Did I unplug the charger?"),
            ParanoiaItem(title: "Did I close the windows?"),
            ParanoiaItem(title: "Do I have my keys?"),
            ParanoiaItem(title: "Did I set the alarm?"),
            ParanoiaItem(title: "Did I close the garage door?")
        ]
    }
}

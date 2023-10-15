//
// Prospect.swift
//  HotProspects
//
//  Created by Aaron Brown on 10/13/23.
//

import SwiftUI


// What makes a prospect
class Prospect: Identifiable, Codable {
    fileprivate(set) var id = UUID()
    var name: String = "Testing"
    var email: String = "prospect@Email.com"
    // fileprivate(set) allows the property to be read from outside the file. However it can only be written to within this file.
    fileprivate(set) var isContacted: Bool = false
}

// What makes prospects
@MainActor class Prospects: ObservableObject {
    @Published fileprivate(set) var people: [Prospect]
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "SavedData") {
            if let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
                people = decoded
                return
            }
        }
        // No saved data.
        people = []
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(people) {
            UserDefaults.standard.set(encoded, forKey: "SavedData")
        }
    }
    
    func toggle(_ person: Prospect) {
        objectWillChange.send()
        person.isContacted.toggle()
        save()
    }
    
    func add(_ person: Prospect) {
        people.append(person)
        save()
        return
    }
    
    func remove(_ person: Prospect) {
        // Find the index of the person object
        if let index = people.firstIndex(where: { $0.id == person.id }) {
            // Remove the person object from the array
            people.remove(at: index)
            // Save the changes
            save()
        }
    }
}

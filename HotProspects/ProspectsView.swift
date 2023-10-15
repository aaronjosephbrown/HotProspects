//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Aaron Brown on 10/13/23.
//

import CodeScanner
import SwiftUI
import UserNotifications

struct ProspectsView: View {
    @State private var isShowingScanner = false
    
    enum FilterType {
        case none, contacted, uncontacted
    }
    @EnvironmentObject var prospects: Prospects
    let filterType: FilterType
    
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredProspect) { person in
                    VStack(alignment: .leading) {
                        Text(person.name)
                            .font(.headline)
                        Text(person.email)
                            .foregroundColor(.secondary)
                    }
                    .swipeActions(edge: .leading) {
                        if person.isContacted {
                            Button {
                                prospects.toggle(person)
                            } label: {
                                Label("Mark as uncontacted",systemImage: "archivebox")
                                    .tint(.yellow)
                            }
                        } else {
                            Button {
                                prospects.toggle(person)
                            } label: {
                                Label("Contacted",systemImage: "checkmark")
                                    .tint(.green)
                            }
                        }
                        Button {
                            addNotification(for: person)
                        } label: {
                            Label("Remind me", systemImage: "bell")
                                .tint(.cyan)
                        }
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            prospects.remove(person)
                        } label: {
                            Label("Delete Person", systemImage: "xmark")
                        }
                    }
                }
            }
            .navigationTitle(title)
            .toolbar {
                Button {
                    isShowingScanner = true
                } label: {
                    Label("Scan", systemImage: "qrcode.viewfinder")
                }
            }
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(codeTypes: [.qr],simulatedData: "Aaron Brown\naaronabrown@me.com", completion: handleScan)
            }
        }
    }
    
    var title: String {
        switch filterType {
        case .none:
            "Everyone"
        case .contacted:
            "Contacted"
        case .uncontacted:
            "Uncontacted"
        }
    }
    
    var filteredProspect: [Prospect] {
        switch filterType {
        case .none:
            prospects.people
        case .contacted:
            prospects.people.filter { $0.isContacted }
        case .uncontacted:
            prospects.people.filter { !$0.isContacted}
        }
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        
        switch result {
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            guard details.count == 2 else { return }
            
            let newProspect = Prospect()
            newProspect.name = details[0]
            newProspect.email = details[1]
            
            prospects.add(newProspect)
            return
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
            return
        }
    }
    
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect)"
            content.subtitle = prospect.email
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.hour = 9
            //            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else {
                        print("Error with notifications")
                    }
                }
            }
        }
    }
}

#Preview {
    ProspectsView(filterType: .none)
        .environmentObject(Prospects())
}

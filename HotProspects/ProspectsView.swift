//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Aaron Brown on 10/13/23.
//

import CodeScanner
import SwiftUI

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
}

#Preview {
    ProspectsView(filterType: .none)
        .environmentObject(Prospects())
}

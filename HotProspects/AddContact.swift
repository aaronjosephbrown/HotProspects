//
//  AddContact.swift
//  HotProspects
//
//  Created by Aaron Brown on 10/15/23.
//

import SwiftUI

struct AddContact: View {
    @EnvironmentObject var prospects: Prospects
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var email: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    TextField("Name", text: $name)
                        .textContentType(.name)
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                    
                    Button("Add Prospect") {
                        if name.isEmpty || email.isEmpty { return }
                        let newprospect = Prospect()
                        newprospect.name = name
                        newprospect.email = email
                        
                        prospects.add(newprospect)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Add Prospect")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    AddContact()
}

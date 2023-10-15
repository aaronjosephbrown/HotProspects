//
//  MeView.swift
//  HotProspects
//
//  Created by Aaron Brown on 10/13/23.
//
import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct MeView: View {
    @State private var name = "Aaron Brown"
    @State private var email = "aaron.brown@me.com"
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        NavigationView {
            Form {
                Image(uiImage: generateQRCode(from: "\(name)\n\(email)"))
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()

                TextField(name, text: $name)
                    .textContentType(.name)
                    .font(.title)
                
                TextField(email, text: $email)
                    .textContentType(.emailAddress)
                    .font(.title)
            }
            .navigationTitle("Title")
        }
    }
    
    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

#Preview {
    MeView()
}

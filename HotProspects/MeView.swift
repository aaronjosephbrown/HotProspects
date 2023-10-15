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
    @StateObject var user = User()
    @State private var qrCode = UIImage()
    
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        NavigationView {
            Form {
                Image(uiImage: qrCode)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .contextMenu {
                        Button {
                            let imageSavor = ImageSaver()
                            imageSavor.writeToSavePhotoAlbum(image: qrCode)
                            
                            imageSavor.successHandler = {
                                print("Saved")
                            }
                            
                            imageSavor.errorHandler = { error in
                                print(error.localizedDescription)
                            }
                        } label: {
                            Label("Save to Photos", systemImage: "square.and.arrow.down")
                        }
                    }
                VStack {
                    TextField(user.username, text: $user.username)
                        .textContentType(.name)
                        .font(.title)
                    
                    TextField(user.userEmail, text: $user.userEmail)
                        .textContentType(.emailAddress)
                        .font(.title)
                }
                .onChange(of: [user.username, user.userEmail]) { _,_ in
                    updateCode()
                    user.save()
                }
            }
            .navigationTitle("My Contact Info")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                updateCode()
            }
        }
    }
    
    func updateCode() {
        qrCode = generateQRCode(from: "\(user.username)\n\(user.userEmail)")
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
    MeView(user: User())
}

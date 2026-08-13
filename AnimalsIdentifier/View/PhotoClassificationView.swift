import SwiftUI
import PhotosUI
import Vision
import Foundation
import AVFoundation

@MainActor
struct PhotoClassificationView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var selectedImage2: CGImage?
    @State private var photoResult: VNClassificationObservation? // classificação da imagem
    //@State private var result: CapturedImageResult?
    private let classificationService = AnimalClassificationService()

    var body: some View {
        NavigationStack {
            
                ZStack {
                    
                    Color
                        .indigo
                        .opacity(0.6)
                        .ignoresSafeArea()

                    ScrollView {
                    VStack(spacing: 16) {
                        HeaderView(title: "Animal identifier", symbol: "cat", subtitle: "Choose a picture to identify an animal")
                            
                        if let img = selectedImage {
                            
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 400)
                            
                        }
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            Label("Choose an image", systemImage: "photo")
                                .tint(Color.white)
                        }
                        
                        .onChange(of: selectedItem) {_, item in
                            Task {
                                if let data = try? await item?.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                                    selectedImage = uiImage
                                    
                                    photoResult = try classificationService.classify2(uiImage)
                                   
                                }
                            }
                        }
                        Spacer()
                  
                        
                        //checa se a confiança é o suficiente pra afirmar animal
                        //jogar isso no service
                        
                        if let result = (photoResult?.confidence ?? 0 > 0.4 ? photoResult : nil) {
                            Text("Probably: \(result.identifier.uppercased(with: Locale.current)), \(Int(result.confidence * 100))%")
                                .font(.headline)
                            AnimalCuriositiesView(animal: result.identifier)
                        } else {
                            Text("Unidentified...")
                                .foregroundColor(Color.white)
                        }
                    }
                  //  .navigationTitle("Image Classification")
                    .padding()
                }
                    .scrollIndicators(.hidden)

            }
        }
    }
}
#Preview {
    PhotoClassificationView()
}

import SwiftUI
import PhotosUI
import Vision
import Foundation
import AVFoundation


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

                
                VStack(spacing: 16) {
                    HeaderView(title: "Animal identifier", symbol: "cat", subtitle: "Escolha uma imagem para identificar o animal.")
                        
                    if let img = selectedImage {
                        
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 400)
                    }
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Label("Escolha uma imagem", systemImage: "photo")
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
                        Text("\(result.identifier), \(Int(result.confidence * 100))%")
                            .font(.headline)
                    } else {
                        Text("Não identificado")
                            .foregroundColor(Color.white)
                    }
                }
              //  .navigationTitle("Image Classification")
                .padding()
            }
        }
    }
}
#Preview {
    PhotoClassificationView()
}

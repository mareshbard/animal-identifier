import SwiftUI
import PhotosUI
import Vision


struct PhotoClassificationView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var photoResult: VNClassificationObservation? // classificação da imagem
    
    var body: some View {
            NavigationStack {
            VStack(spacing: 16) {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Label("Escolha uma imagem", systemImage: "photo")
                }
                .onChange(of: selectedItem) { item in
                    Task {
                        if let data = try? await item?.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                            selectedImage = uiImage
                            //   photoResult = try? InferenceService.shared.classify(uiImage)
                        }
                    }
                }
                
                if let img = selectedImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                }
                
                //checa se a confiança é o suficiente pra afirmar animal
                //jogar isso no service
                if let result = (photoResult?.confidence ?? 0 > 0.4 ? photoResult : nil) {
                    Text("\(result.identifier), \(Int(result.confidence * 100))%")
                        .font(.headline)
                } else {
                    Text("Não identificado")
                }
            }
            .navigationTitle("Image Classification")
            .padding()
        }
    }
}

#Preview {
    PhotoClassificationView()
}

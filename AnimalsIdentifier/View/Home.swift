import SwiftUI
import PhotosUI
import Vision

struct ContentView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var photoResult: VNClassificationObservation? // classificação da imagem
    
    var body: some View {
       TabView {
            AnimalClassifierView()
               .tabItem {
                   Label("Live", systemImage: "camera.viewfinder")//
               }
               PhotoClassificationView()
               .tabItem {
                   Label("Photo", systemImage: "camera")
               }

        }
    }
}

#Preview {
    ContentView()
}

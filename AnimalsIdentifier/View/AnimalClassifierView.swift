import Foundation
import SwiftUI
import Observation
import Vision


struct AnimalClassifierView: View {
    @State private var viewModel = AnimalClassifierViewModel()
    
    var body: some View {
        ZStack {
            Color
                .indigo
                .opacity(0.6)
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    HeaderView(title: "Animal identifier", symbol: "hare", subtitle: "Identifique animais com a sua camera. É possível reconhecer 90 animais atualmente.")
                    CameraCard()
                    ActionView()
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
        .foregroundStyle(Color(.white))
       
    }
}



#Preview {
    AnimalClassifierView()
}

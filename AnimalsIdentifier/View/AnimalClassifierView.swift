import Foundation
import SwiftUI
import Observation
import Vision

// MARK: Status mostrado na tela
enum ClassificationStatus: Equatable {
    case idle
    case analyzing
    case result(ClassificationResult) // resultado acima ou igual ao threshold escolhido
    case unknown(bestMatch: Animal?, confidence: Double?) // devolve o melhorzinho, se encontrado
    case failure(String) // mostra erro
    
    static func decision(for result: ClassificationResult, threshold: Double) -> Self {
        if result.confidence > threshold {
            .result(result)
        } else {
            .unknown(bestMatch: result.animal, confidence: result.confidence)
        }
    }
}



// MARK: Tela de captura de foto

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
        .task {
            await viewModel.prepareCamera()
        }
    }
}



#Preview {
    AnimalClassifierView()
}

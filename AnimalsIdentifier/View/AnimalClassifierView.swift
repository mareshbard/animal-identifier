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
                    HeaderView(title: "Animal identifier", symbol: "hare", subtitle: "Capable of identifying 90 animals")
                cameraCard
                
                    actionArea
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
        .foregroundStyle(Color(.white))
       
    }
    private func cameraPlaceholder(icon: String, message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                Text(message)
        }
        .foregroundStyle(Color(.white.opacity(0.5)))
    }
    
    private var cameraCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.pink.opacity(0.3))
            
            switch viewModel.cameraStatus {
            case .ready:
                CameraPreview(session: viewModel.cameraService.session)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            case .preparing:
                cameraPlaceholder(icon: "camera", message: "Preparing camera")
            case .failed(let message):
                cameraPlaceholder(icon: "camera.fill", message: message)
            }
            
            RoundedRectangle(cornerRadius: 18)
                .stroke(.black, style: StrokeStyle(lineWidth: 2, dash: [10, 6]))
                .padding(16)
        }
        .task {
            await viewModel.prepareCamera()
        }
        .frame(height: 400)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        
    
    }
    @ViewBuilder
    private var actionArea: some View {

            // MARK: Status mostrado na tela
            
            switch viewModel.status {
                
            case .idle:
                inputButtons
                
            case .analyzing:
                VStack {
                    ProgressView()
                        .tint(.white)
                    Text("Analyzing...")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                
            case .result(let classificationResult):
                
                Button("Try again", action: viewModel.tryAgain)
                    .buttonStyle(.borderedProminent)
                    .foregroundStyle(.black)
                    .controlSize(.large)
                
                AnimalCuriositiesView(animal: classificationResult.animal.displayName)
                
            case .unknown(let bestMatch, let confidence):
                ResultCard(title: "Not sure", message: bestMatch.map {"Closest match: \($0.displayName)" } ?? "No matchs", confidence: confidence, accent: .orange, onTryAgain: viewModel.tryAgain)
                
            case .failure(let message):
                ResultCard(title: "Try again", message: message, confidence: nil, accent: .red, onTryAgain: viewModel.tryAgain)
            }
        }
        private var inputButtons: some View {
            Button {
                Task {
                    await viewModel.captureAndClassify()
                }
            } label: {
                Label("Recognize", systemImage: "viewfinder")
                    .frame(maxWidth: .infinity, minHeight: 52)
            }
            .buttonStyle(.borderedProminent)
            .tint(.white)
            .foregroundStyle(.pink)
            .disabled(!viewModel.canUseCamera)
        }
        
    }

    

private struct ResultCard: View {
    let title: String
    let message: String
    let confidence: Double?
    let accent: Color
    let onTryAgain: () -> Void
    
    var body: some View {
        
        
        VStack(spacing: 16) {
            Text(title)
                .font(.title)
                .bold()
                .foregroundColor(accent)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
            if let confidence {
                Text("Confidence: \(Int(confidence * 100))%")
            }
            Button("Try again", action: onTryAgain)
                .buttonStyle(.borderedProminent)
                .tint(accent)
                .foregroundStyle(.black)
                .controlSize(.large)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20) .stroke(accent.opacity(0.5)))
        
    }
}
#Preview {
    AnimalClassifierView()
}

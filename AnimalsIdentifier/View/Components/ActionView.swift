//
//  ActionView.swift
//  AnimalsIdentifier
//
//  Created by Leticia Gomes on 12/08/26.
//

import SwiftUI

struct ActionView: View {
    @State private var viewModel = AnimalClassifierViewModel()
    @ViewBuilder
    var body: some View {
        
        
        switch viewModel.status {
            
        case .idle:
            inputButtons
            
        case .analyzing:
            VStack {
                ProgressView()
                    .tint(.white)
                Text("Analisando imagem")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            
        case .result(let classificationResult):
            
            Button("Tente novamente", action: viewModel.tryAgain)
                .buttonStyle(.borderedProminent)
                .foregroundStyle(.black)
                .controlSize(.large)
            
            AnimalCuriositiesView(animal: classificationResult.animal.displayName)
            
        case .unknown(let bestMatch, let confidence):
            ResultCard(title: "Sem certeza", message: bestMatch.map {"Correspondencia próxima: \($0.displayName)" } ?? "No matchs", confidence: confidence, accent: .orange, onTryAgain: viewModel.tryAgain)
            
        case .failure(let message):
            ResultCard(title: "Tente novamente", message: message, confidence: nil, accent: .red, onTryAgain: viewModel.tryAgain)
        }
    }
    private var inputButtons: some View {
        Button {
            Task {
                await viewModel.captureAndClassify()
            }
        } label: {
            Label("Reconhecer animal", systemImage: "viewfinder")
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
    ActionView()
}

//
//  CameraCard.swift
//  AnimalsIdentifier
//
//  Created by Leticia Gomes on 12/08/26.
//

import SwiftUI

struct CameraCard: View {
    @State private var viewModel = AnimalClassifierViewModel()
    var body: some View {
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
        
        .frame(height: 400)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        
    }
    
    private func cameraPlaceholder(icon: String, message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                Text(message)
        }
        .foregroundStyle(Color(.white.opacity(0.5)))
    }
}

#Preview {
    CameraCard()
}

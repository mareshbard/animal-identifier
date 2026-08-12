//
//  HeaderView.swift
//  AnimalsIdentifier
//
//  Created by Leticia Gomes on 12/08/26.
//

import SwiftUI

struct HeaderView: View {
    var title: String
    var symbol: String
    var subtitle: String
    
    var body: some View {
      
            VStack(spacing: 8) {
                Label("\(title)", systemImage: "\(symbol)")
                    .font(.largeTitle)
                    .bold()
                Text(subtitle)
                    .font(.subheadline)
                   // .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            
        }
            .foregroundStyle(Color.primary)
    }
}

#Preview {
    HeaderView(title: "Photo identifier", symbol: "cat", subtitle: "Escolha uma imagem para identificar o animal.")
}

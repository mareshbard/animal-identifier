import Foundation
import SwiftUI
import FoundationModels

struct AnimalCuriositiesView: View {
    @State private var language: String = "British"
    
    let languages = [
        "English",
        "French",
        "German",
        "Portuguese"
    ]
    
    var animal: String
    @State var response: AnimalFM = AnimalFM(
        name: "Cat",
        phrases: ["Cats are amazing"]
    )

    var body: some View {
        VStack(alignment: .leading) {
            
            Picker("Type", selection: $language) {
                ForEach(languages, id: \.self) { l in
                    Text(l)
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            VStack(alignment: .leading) {
                Text("Animal:")
                    .font(.title)
                    .padding(.bottom)
                Text("Name: \(response.name)")
                ForEach(response.phrases, id: \.self) { ph in
                    Text("\(ph)")
                    
                }
            }
            
            .onChange(of: language) {
                Task {
                    response = await generate(lang: language, animal: animal) ?? AnimalFM(name: "Cat", phrases: ["Cats are amazing"])
                }
            }
        }
    }
    
    func generate(lang: String, animal: String) async -> AnimalFM? {

        do {
            let session = LanguageModelSession()
            let response = try await session.respond(
                to: "Generate in \(lang) for \(animal)",
                generating: AnimalFM.self
            )

            return response.content
        } catch {
            
        }
        return nil
    }
}

#Preview {
    AnimalCuriositiesView(animal: "Cat")
}

import FoundationModels
import Playgrounds

@Generable
struct AnimalFM {
    @Guide(description: "The animal name")
    let name: String
    
    @Guide(description: "Phrases about the animal")
    let phrases: [String]

}


#Playground {
    let session = LanguageModelSession()
    let response = try await session.respond(
        to: "Generate in French",
        generating: AnimalFM.self
    )
}

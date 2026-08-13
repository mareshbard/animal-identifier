import CoreML
import Foundation
import Vision
import UIKit

enum ClassificationError: Error {
    case message(String)
}

struct ClassificationResult: Equatable {
    let animal: Animal
    let confidence: Double
}

class AnimalClassificationService {
    
    let confidenceThreshold: Double
    
    init(confidenceThreshold: Double = 0.80) {
        self.confidenceThreshold = confidenceThreshold
    }
    
    func classify(_ image: CapturedImage) async throws -> ClassificationResult {
        
        let mlModel = try loadModel()
        let visionModel = try adaptModelToVision(mlModel)
        let request = makeClassificationRequest(using: visionModel)
        let observations = try performRequest(request, on: image)
        
        return try interpret(observations)
    }
    
 
    // carregando modelo
    private func loadModel() throws -> MLModel {
        
        guard let modelURL = Bundle.main.url(
            forResource: "AnimalClassifier",
            withExtension: "mlmodelc"
        ) else {
            throw ClassificationError.message("Could not locate the Core ML model file.")
        }
        
        do {
            return try MLModel(contentsOf: modelURL)
        } catch {
            throw ClassificationError.message("Could not load the model")
        }
        
    }
    
    private func adaptModelToVision(_ mlModel: MLModel) throws -> VNCoreMLModel {
        
        // VNCoreMLModel: classe que conecta o modelo treinado (CoreML) ao Vision (framework)
        
        do {
            return try VNCoreMLModel(for: mlModel)
        } catch {
            throw ClassificationError.message("Could not adapt model to Vision")
        }
    }
    
    private func makeClassificationRequest(using visionModel: VNCoreMLModel) -> VNCoreMLRequest {
        // VNCoreMLRequest: é o pedido para usar o classificador (CoreML) na imagem
        let request = VNCoreMLRequest(model: visionModel)
        
        request.imageCropAndScaleOption = .centerCrop
        return request
    }
    
    private func performRequest(_ request: VNCoreMLRequest, on image: CapturedImage) throws -> [VNClassificationObservation] {
        let handler = VNImageRequestHandler(
            cgImage: image.cgImage,
            orientation: image.orientation,
            options: [:]
        )
        
        do {
            try handler.perform([request])
        } catch {
            throw ClassificationError.message("Could not perform request")
        }
        
        guard let rawResults = request.results else {
            throw ClassificationError.message("No results found")
        }
        
        // tenta converter os resultados p/ uma array de observações
        guard let observations = rawResults as? [VNClassificationObservation] else {
            throw ClassificationError.message("No results found")
        }
        
        return observations
        
    }
        private func interpret(_ observations: [VNClassificationObservation]) throws -> ClassificationResult {
            let predictions = observations.map {
                (identifier: $0.identifier, confidence: $0.confidence)
            }
            return try Self.interpretPredictions(predictions)
        }
    
    // retorna as predições em um array de tuplas (identifier, confidence)
    
    static func interpretPredictions(_ predictions: [(identifier: String, confidence: Float)]) throws -> ClassificationResult {
        
        guard let best = predictions.max(by: { $0.confidence < $1.confidence}) else {
            throw ClassificationError.message("No animal detected")
        }
        
        guard let animal = Animal(rawValue: best.identifier) else {
            throw ClassificationError.message("Unknown animal detected")
        }
        return ClassificationResult(animal: animal, confidence: Double(best.confidence))
    }
    
    
    func classify2(_ image: UIImage) throws -> VNClassificationObservation? {
        let mlModel = try loadModel()
        guard let cg = image.cgImage else { return nil }
        do {
            let vnModel = try VNCoreMLModel(for: mlModel) // usado para tarefas de reconhecimento visual
            let request = VNCoreMLRequest(model: vnModel)
            let handler = VNImageRequestHandler(cgImage: cg, orientation: .up)
            try handler.perform([request])
        let results = (request.results as? [VNClassificationObservation]) ?? []
            let sorted  = results.sorted { $0.confidence > $1.confidence }
            let top5 = sorted.prefix(5).map { "\($0.identifier)=\(Int($0.confidence * 100))%" }
            print(top5)
            return sorted.first
            
        } catch {
            print(error)
        }
        return nil
    }
    
}

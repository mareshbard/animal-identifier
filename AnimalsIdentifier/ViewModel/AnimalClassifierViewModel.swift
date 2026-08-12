import Foundation


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

// MARK: View model

@MainActor // garante que o código sempre rode na thread principal, usado quando o modelo atualiza algo que UI observa
@Observable
class AnimalClassifierViewModel {
    var status: ClassificationStatus = .idle
    var cameraStatus = CameraService.Status.preparing
    let cameraService = CameraService()
    private let classificationService = AnimalClassificationService()
    
    var isAnalyzing: Bool {
        status == .analyzing
    }
    
    var canUseCamera: Bool {
        cameraStatus == .ready && !isAnalyzing
    }
    
    func prepareCamera() async {
        await cameraService.prepare()
        cameraStatus = cameraService.status
    }
    
    func captureAndClassify() async {
        guard !isAnalyzing else { return }
        status = .analyzing
        
        do {
            let image = try await cameraService.capturePhoto()
            let result = try await classificationService.classify(image)
            status = .decision(
                for: result,
                threshold: classificationService.confidenceThreshold
            )
            
        } catch {
            status = .failure(error.localizedDescription)
        }
    }
    func tryAgain() {
        status = .idle
    }
}

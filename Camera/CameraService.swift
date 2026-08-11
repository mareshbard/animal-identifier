import AVFoundation
import Foundation
import UIKit

struct CapturedImage: @unchecked Sendable {
    let cgImage: CGImage
    let orientation: CGImagePropertyOrientation
}

enum CameraError: LocalizedError, Equatable {
    case permissionDenied
    case unavailable
    case captureFailed

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            "Camera permission denied"
        case .unavailable:
            "Camera is unavailable"
        case .captureFailed:
            "Failed to capture image"
        }
    }}

class CameraService: NSObject, @unchecked Sendable {
    enum Status: Equatable {
        case preparing
        case ready
        case failed(String)
    }

    let session = AVCaptureSession()
    private(set) var status: Status = .preparing

    private let photoOutput = AVCapturePhotoOutput()
    private var continuation: CheckedContinuation<CapturedImage, Error>?

    func prepare() async {
        status = .preparing
        guard await requestPermission() else {
            status = .failed(CameraError.permissionDenied.localizedDescription)
            return
        }
        guard configureSession() else {
            status = .failed(CameraError.unavailable.localizedDescription)
            return
        }
        await session.startRunning()
        status = .ready
    }

    private func requestPermission() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: true
        case .notDetermined: await AVCaptureDevice.requestAccess(for: .video)
        default: false
        }
    }

    private func configureSession() -> Bool {
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera),
              session.canAddInput(input),
              session.canAddOutput(photoOutput) else {
            return false
        }
        session.beginConfiguration()
        session.sessionPreset = .photo
        session.addInput(input)
        session.addOutput(photoOutput)
        session.commitConfiguration()
        return true
    }

    func capturePhoto() async throws -> CapturedImage {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        }
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        defer { continuation = nil }
        if let error {
            continuation?.resume(throwing: error)
        } else if let data = photo.fileDataRepresentation(),
                  let image = UIImage(data: data),
                  let cgImage = image.cgImage {
            continuation?.resume(
                returning: CapturedImage(
                    cgImage: cgImage,
                    orientation: image.imageOrientation.cgImagePropertyOrientation
                )
            )
        } else {
            continuation?.resume(throwing: CameraError.captureFailed)
        }
    }
}

private extension UIImage.Orientation {

    var cgImagePropertyOrientation: CGImagePropertyOrientation {
        switch self {
        case .up: .up
        case .down: .down
        case .left: .left
        case .right: .right
        case .upMirrored: .upMirrored
        case .downMirrored: .downMirrored
        case .leftMirrored: .leftMirrored
        case .rightMirrored: .rightMirrored
        }
    }
}

import AppKit
import CoreImage

enum QRScan {
    /// `rect` en coordenadas Quartz globales (origen arriba-izquierda).
    static func scan(rect: CGRect) -> String? {
        // ponytail: CGWindowListCreateImage está deprecated desde macOS 14 pero sigue
        // funcionando y es síncrona/una línea. Si Apple la retira, migrar a
        // SCScreenshotManager.captureImage(contentFilter:configuration:) de ScreenCaptureKit.
        guard let cgImage = CGWindowListCreateImage(rect, .optionAll, kCGNullWindowID, .bestResolution) else {
            return nil
        }
        let ciImage = CIImage(cgImage: cgImage)
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let features = detector?.features(in: ciImage) as? [CIQRCodeFeature]
        return features?.first?.messageString
    }
}

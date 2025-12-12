//
//  UIImage+.swift
//  Data
//
//  Created by 박민서 on 1/26/25.
//  Copyright © 2025 yapp25thTeamTnT. All rights reserved.
//

import UIKit

extension UIImage {
    /// 이미지 타입을 유지하면서 최대 크기(바이트) 이하로 압축된 데이터를 반환
    /// - Parameters:
    ///   - maxSizeMB: 최대 허용 크기(MB)
    ///   - isPNG: 원본이 PNG인 경우, PNG로 압축할지 여부 (기본값: true)
    /// - Returns: 압축된 이미지 데이터 (JPEG 또는 PNG)
    /// - Note: PNG 압축은 무손실이지만, 크기 감소 효과가 적고 시간이 오래 걸릴 수 있습니다.
    ///         JPEG 압축은 손실 압축이지만 크기를 크게 줄일 수 있습니다.
    func compressedData(maxSizeMB: Double = 10.0, isPNG: Bool = false) -> Data? {
        let maxSizeBytes: Int = Int(maxSizeMB * 1024 * 1024)
        
        // PNG로 압축
        if isPNG, let pngData = self.pngData(), pngData.count <= maxSizeBytes {
            return pngData
        }
        
        // JPEG로 압축
        var compression: CGFloat = 1.0
        var imageData: Data? = self.jpegData(compressionQuality: compression)

        while let data = imageData, data.count > maxSizeBytes, compression > 0.1 {
            compression -= 0.1
            imageData = self.jpegData(compressionQuality: compression)
        }
        
        return imageData
    }

}

extension Data {
    enum ImageFormat {
        case jpeg
        case png
        case unknown

        var fileExtension: String {
            switch self {
            case .jpeg, .unknown:
                return "jpg"
            case .png:
                return "png"
            }
        }

        var mimeType: String {
            switch self {
            case .jpeg, .unknown:
                return "image/jpeg"
            case .png:
                return "image/png"
            }
        }
    }

    var imageFormat: ImageFormat {
        let pngSignature: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]

        if self.starts(with: [0xFF, 0xD8]) {
            return .jpeg
        } else if self.starts(with: pngSignature) {
            return .png
        }

        return .unknown
    }
}

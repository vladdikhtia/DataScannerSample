//
//  ScannerViewModel.swift
//  DataScannerSmaple
//
//  Created by Vladyslav Dikhtiaruk on 16/01/2024.
//

import Foundation
import UIKit
import VisionKit
import AVKit

enum ScanType: String {
    case barcode, text
}

enum DataScannerAccessType {
    case notDetermined,
         cameraAccessNotGranted,
         cameraNotAvailable,
         scannerAvailable,
         scannerNotAvailable
}


@MainActor // inside the main thread
class ScannerViewModel: ObservableObject {
        
    @Published var dataScannerAccessStatus: DataScannerAccessType = .notDetermined
    
    @Published var recognizedItems: [RecognizedItem] = []
    @Published var scanType: ScanType = .text
    @Published var textContentType: DataScannerViewController.TextContentType?
//    @Published var recognizesMultipleItems = false
    
    var recognizedDataType: DataScannerViewController.RecognizedDataType = .text()
//        scanType == .barcode ? .barcode() :
//            .text(textContentType: textContentType)
//    }
    
    var headerText: String {
        if recognizedItems.isEmpty {
            return "Scanning \(scanType.rawValue)"
        } else{
            return "Recognized \(recognizedItems.count) item(s)"
        }
    }
    
    var dataScannerViewId: Int {
        var hasher = Hasher()
        hasher.combine(scanType)
//       hasher.combine(recognizesMultipleItems)
        if let textContentType{
            hasher.combine(textContentType)
        }
        return hasher.finalize()
    }
    
    private var isScannerAvailable: Bool {
        DataScannerViewController.isAvailable && DataScannerViewController.isSupported
    }
    
    func requestDataScannerAccessStatus() async {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { // device has camera
            dataScannerAccessStatus = .cameraNotAvailable
            return
        }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) { // permission
        case .authorized:
            dataScannerAccessStatus = isScannerAvailable ? .scannerAvailable : .scannerNotAvailable
            
        case .restricted, .denied:
            dataScannerAccessStatus = .cameraAccessNotGranted
            
        case .notDetermined:
            let granted: Bool = await AVCaptureDevice.requestAccess(for: .video)
            if granted {
                dataScannerAccessStatus = isScannerAvailable ? .scannerAvailable : .scannerNotAvailable
            } else {
                dataScannerAccessStatus = .cameraAccessNotGranted
            }
            
        default:
            break
        }
        
    }
    
}

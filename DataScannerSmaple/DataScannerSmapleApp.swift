//
//  DataScannerSmapleApp.swift
//  DataScannerSmaple
//
//  Created by Vladyslav Dikhtiaruk on 16/01/2024.
//

import SwiftUI

@main
struct DataScannerSmapleApp: App {
    
    @StateObject private var viewModel = ScannerViewModel()


    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .task {
                    await viewModel.requestDataScannerAccessStatus()
                }
        }
    }
}

//
//  ContentView.swift
//  DataScannerSmaple
//
//  Created by Vladyslav Dikhtiaruk on 16/01/2024.
//

import SwiftUI
import VisionKit

struct ContentView: View {
    @EnvironmentObject var viewModel: ScannerViewModel
    
    
    private let textContentTypes: [(title: String, textContentType: DataScannerViewController.TextContentType?)] = [ // Dictionary
        ("All", .none),
        ("URL", .URL),
        ("Phone", .telephoneNumber),
        ("Email", .emailAddress),
        ("Address", .fullStreetAddress)
    ]
    
    
    var body: some View {
        
        switch viewModel.dataScannerAccessStatus {
            
        case .scannerAvailable:
            mainView
            //Text("Scanner is available")
        case .cameraNotAvailable:
            Text("Your device doesn't have a camera!")
        case .scannerNotAvailable:
            Text("Your device doesn't have support for scanning") // 2018 +
        case .cameraAccessNotGranted:
            Text("Please provide camera access in settings")
        case .notDetermined:
            Text("Requesting camera access")
        }
    }
    
    private var mainView: some View {
        VStack{
            DataScannerView(
                recognizedItems: $viewModel.recognizedItems
                //recognizedDataType: viewModel.recognizedDataType
               // recognizesMultipleItems: viewModel.recognizesMultipleItems
            )
            .background { Color.gray.opacity(0.3) }
            .ignoresSafeArea()
            .id(viewModel.dataScannerViewId)
            
            VStack{
                headerView
                ScrollView {
                    LazyVStack(alignment: .leading,spacing: 16) {
                        ForEach(viewModel.recognizedItems) { item in
                            switch item {
                            case .barcode(let barcode):
                                Text(barcode.payloadStringValue ?? "Unknown Barcode")
                                        
                            case .text(let text):
                                Text(text.transcript)
                            @unknown default:
                                Text("Unknown")
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: viewModel.scanType) { viewModel.recognizedItems = [] }
        .onChange(of: viewModel.textContentType) { viewModel.recognizedItems = [] }
//        .onChange(of: viewModel.recognizesMultipleItems, { viewModel.recognizedItems = [] })
    }
    
    private var headerView: some View {
        VStack{
            HStack{
                Picker("Scan Type", selection: $viewModel.scanType) {
                    Text("Barcode").tag(ScanType.barcode)
                    Text("Text").tag(ScanType.text)
                }
                .pickerStyle(.segmented)
                
//                Toggle("Scan Multiple", isOn: $viewModel.recognizesMultipleItems) // 38:00
                   
            }
            .padding(.top)
            
            if (viewModel.scanType) == .text {
                Picker("Text Content Type", selection: $viewModel.textContentType){
                    ForEach(textContentTypes, id: \.self.textContentType) { option in
                        Text(option.title).tag(option.textContentType)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Text(viewModel.headerText)
                .padding(.top)
        }
        .padding(.horizontal)
    }
}



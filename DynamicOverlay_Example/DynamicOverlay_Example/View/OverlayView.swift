//
//  OverlayView.swift
//  DynamicOverlay_Example
//
//  Created by Gaétan Zanella on 17/04/2021.
//  Copyright © 2021 Fabernovel. All rights reserved.
//

import Foundation
import SwiftUI
import DynamicOverlay

struct OverlayView: View {

    enum Event {
        case didBeginEditing
        case didEndEditing
    }

    let eventHandler: (Event) -> Void

    // MARK: - View
    
    @State var sheetPrez: Bool = false
    @State var sheetPrezB: Bool = false

    
    @State var selectedHScreen: Int? = nil
    
    var body: some View {
        VStack(spacing: 0.0) {
            header.draggable()
            
//            testTxtInput
//                .draggable()
                
            
//            ScrollView(.horizontal) {
//                HStack(spacing: 0) {
//                    list
//                        .containerRelativeFrame(.horizontal)
////                        .drivingScrollView()
//
//                    testContent()
//                        .containerRelativeFrame(.horizontal)
//
//                    testContent()
//                        .id("test2")
//                        .containerRelativeFrame(.horizontal)
//
//                }
//            }
//            .drivingScrollView()

            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    list
                        .containerRelativeFrame(.horizontal)
                        .drivingScrollView(selectedHScreen == 1)
                        .id(1)
                    
                    sheetA
                        .containerRelativeFrame(.horizontal)
//                        .drivingScrollView()
                        .drivingScrollView(selectedHScreen == 2)
                        .id(2)
                    
                    testContent()
                        .containerRelativeFrame(.horizontal)
                        .id(3)
                    
                    testContent()
                        .id("test2")
                        .containerRelativeFrame(.horizontal)
                        .id(4)
                    
                    
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $selectedHScreen, anchor: .center)
            .onChange(of: selectedHScreen) { oldValue, newValue in
                debugPrint("Selected HScreen: \(newValue) -- old: \(oldValue)")
                
            }
//            list
//                .scrollContentBackground(.hidden)
//                .listRowBackground(Color.pink.opacity(0.4))
//                .drivingScrollView()
        }
        .background(OverlayBackgroundView())
//        .drivingScrollView()
        .sheet(isPresented: $sheetPrez, content: {
            sheetA
            .presentationBackground(.ultraThinMaterial)
            .presentationDetents([.fraction(0.60)])
            .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.60)))
//            .presentationDetents([.fraction(0.30)])
//            .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.30)))
            .presentationDragIndicator(.visible)
            
        })
        .onChange(of: testTxtFocus) { oldValue, newValue in
            guard oldValue != newValue else { return }
            
            if newValue {
                eventHandler(.didBeginEditing)
            } else {
                eventHandler(.didEndEditing)
            }
        }
    }
    
    @FocusState var testTxtFocus: Bool
    @State var testTxtInputStr: String = ""
    
    @ViewBuilder
    var testTxtInput: some View {
        HStack {
            TextField("Test", text: $testTxtInputStr, axis: .vertical)
                .lineLimit(2)
                .focused($testTxtFocus)
                .textFieldStyle(.roundedBorder)
            
            Button {
                if testTxtFocus {
                    testTxtInputStr = ""
                    testTxtFocus = false
                } else {
                    testTxtFocus = true
                }
                
            } label: {
                if testTxtFocus {
                    Text("Cancel")
                } else {
                    Text("Search")
                }
            }
        }
        .contentShape(.rect)
        
        
    }
    
    
    @ViewBuilder
    func testContent() -> some View {
        ZStack {
            Color.pink.opacity(0.5)
                .zIndex(1)
            
            Text("Hello World")
                .zIndex(2)
        }
        .ignoresSafeArea()
        
    }
    
    var sheetA: some View {
        NavigationStack {
            List {
                Section(header: Text("Favorites")) {
                    ScrollView(.horizontal) {
                        HStack {
                            FavoriteCell(imageName: "house.fill", title: "House")
                            FavoriteCell(imageName: "briefcase.fill", title: "Work")
                            FavoriteCell(imageName: "plus", title: "Add")
                        }
                    }
                }
                Section(header: Text("My Guides")) {
                    NavigationLink {
                        VStack {
                            Text("Hello World")
                            Button {
                                sheetPrezB.toggle()
                            } label: {
                                Text("Show Sheet B")
                            }
                        }
                    } label: {
                        Text("Push Forward")
                    }

                    ActionCell()
                    
                }
            }
            .listStyle(GroupedListStyle())
            .scrollContentBackground(.hidden)
            .listRowBackground(Color.pink.opacity(0.4))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        sheetPrez.toggle()
                    }
                }
            }
        }
        .sheet(isPresented: $sheetPrezB, content: {
            testContent()
        })
    }
    

    // MARK: - Private

    private var list: some View {
        List {
            Section(header: Text("Favorites")) {
                ScrollView(.horizontal) {
                    HStack {
                        FavoriteCell(imageName: "house.fill", title: "House")
                        FavoriteCell(imageName: "briefcase.fill", title: "Work")
                        FavoriteCell(imageName: "plus", title: "Add")
                    }
                }
            }
            Section(header: Text("My Guides")) {
                Button {
                    sheetPrez.toggle()
                } label: {
                    Text("Show Sheet")
                }
                
                ActionCell()
            }
        }
        .listStyle(GroupedListStyle())
    }

    private var header: some View {
        SearchBar { event in
            switch event {
            case .didBeginEditing:
                eventHandler(.didBeginEditing)
            case .didCancel:
                eventHandler(.didEndEditing)
            }
        }
    }
}

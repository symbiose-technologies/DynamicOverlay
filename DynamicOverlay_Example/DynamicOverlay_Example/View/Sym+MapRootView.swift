//////////////////////////////////////////////////////////////////////////////////
//
//  SYMBIOSE
//  Copyright 2023 Symbiose Technologies, Inc
//  All Rights Reserved.
//
//  NOTICE: This software is proprietary information.
//  Unauthorized use is prohibited.
//
// DynamicOverlay_Example
// Created by: Ryan Mckinney on 6/13/24
//
////////////////////////////////////////////////////////////////////////////////

import Foundation
import SwiftUI
import DynamicOverlay

enum SymNotch: CaseIterable, Equatable {
    case micro, min, max
}

struct SymMapRootView: View {

    struct State {
        var notch: SymNotch = .min
        var isEditing = false
        var progress = 0.0
    }
    
    @SwiftUI.State
    var model: DynamicOverlayContainerModel = DynamicOverlayContainerModel()
    
    
    @SwiftUI.State
    private var state = State()

    @SwiftUI.State
    private var selectedHScreen: Int? = 1
    
    // MARK: - View

    var body: some View {
        let _ = Self._printChanges()
        
        
        background
            .hostDynamicOverlay(model: model, overlay: {
                overlay
            })
        
//            .dynamicOverlay(overlay)
            .dynamicOverlayBehavior(behavior)
            .ignoresSafeArea()
            .overlay(alignment: .topLeading) {
                Menu {
                    //toggle notches with a button for each case, wrapping in withanimation
                    ForEach(SymNotch.allCases, id: \.self) { notch in
                        Button {
                            withAnimation {
                                model.explicitlySetActiveNotch(toIdx: SymNotch.index(of: notch))
//                                state.notch = notch
                            }
                        } label: {
                            Text("\(notch)")
                        }
                        .disabled(model.trueActiveNotchIdx == SymNotch.index(of: notch))
//                        .disabled(state.notch == notch)
                    }
                    
                    Menu {
                        Button {
                            withAnimation {
                                selectedHScreen = 1
                                model.explicitlySetActiveNotch(toIdx: SymNotch.index(of: .max))
                            }
                        } label: {
                            Text("1")
                        }
                        Button {
                            withAnimation {
                                selectedHScreen = 2
                                model.explicitlySetActiveNotch(toIdx: SymNotch.index(of: .max))
                            }
                        } label: {
                            Text("2")
                        }
//                        Picker("Selected H Screen", selection: $selectedHScreen) {
//                            Text("1")
//                                .tag(1)
//                            
//                            Text("2")
//                                .tag(2)
//                            
//                        }
                    } label: {
                        Text("Selected H Screen")
                    }
                    
                    
                    Menu {
                        
                        Picker("Notch", selection: $state.notch) {
                            ForEach(SymNotch.allCases, id: \.self) { notch in
                                Text("\(notch)")
                                    .tag(notch)
                            }
                        }
                    } label: {
                        Text("Picker")
                    }
                    
                    
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
            }
        
    }

    
    // MARK: - Private

    private var behavior: some DynamicOverlayBehavior {
        MagneticNotchOverlayBehavior<SymNotch> { notch in
            switch notch {
            case .max:
//                return .fractional(0.8)
                return .fractional(1.0)
            case .min:
                return .fractional(0.3)
            case .micro:
                return .absolute(80)
            }
        }
//        .disable(.min, state.isEditing)
//        .disable(.micro, state.isEditing)
        
        .notchChange($state.notch)
//        .onTranslation { translation in
//            state.progress = translation.progress
//        }
    }

    private var background: some View {
        ZStack {
            MapView()
            BackdropView().opacity(state.progress)
        }
        .ignoresSafeArea()
    }

    private var overlay: some View {
        SymOverlayView(model: model, selectedHScreen: $selectedHScreen) { event in
            switch event {
            case .didBeginEditing:
                state.isEditing = true
                withAnimation { state.notch = .max }
            case .didEndEditing:
                state.isEditing = false
                withAnimation { state.notch = .min }
            }
        }
//        .scrollDismissesKeyboard(.interactively)
        
//        .ignoresSafeArea()
        .safeAreaInset(edge: .top, content: {
            Rectangle()
                .fill(Color.red)
                .frame(height: state.notch == .max ? 100 : 0)
                .ignoresSafeArea()
        })
        .ignoresSafeArea()

    }
    

}


#Preview {
    SymMapRootView()
    
}





struct SymOverlayView: View {

    @Bindable var model: DynamicOverlayContainerModel
    
    enum Event {
        case didBeginEditing
        case didEndEditing
    }

    @Binding var selectedHScreen: Int?
//    @State var selectedHScreen: Int? = nil
    
    let eventHandler: (Event) -> Void

    // MARK: - View
    
    @State var sheetPrez: Bool = false
    @State var sheetPrezB: Bool = false

    
    var body: some View {
        let _ = Self._printChanges()
        
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
//                        .drivingScrollView(selectedHScreen == 1)
                        .drivingScrollViewId("1")
                        .id(1)
                    
                    sheetA
                        .containerRelativeFrame(.horizontal)
//                        .drivingScrollView()
//                        .drivingScrollView(selectedHScreen == 2)
                        .drivingScrollViewId("2")
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
            .scrollPosition(id: $selectedHScreen, anchor: .leading)
            
            
//            list
//                .scrollContentBackground(.hidden)
//                .listRowBackground(Color.pink.opacity(0.4))
//                .drivingScrollView()
        }
        .background(OverlayBackgroundView())
        .onChange(of: selectedHScreen) { oldValue, newValue in
            debugPrint("Selected HScreen: \(newValue) -- old: \(oldValue)")
            model.setActiveScrollViewId(newValue == nil ? nil : "\(newValue!)")
        }
//        .drivingScrollView()
//        .sheet(isPresented: $sheetPrez, content: {
//            sheetA
//            .presentationBackground(.ultraThinMaterial)
//            .presentationDetents([.fraction(0.60)])
//            .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.60)))
////            .presentationDetents([.fraction(0.30)])
////            .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.30)))
//            .presentationDragIndicator(.visible)
//            
//        })
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

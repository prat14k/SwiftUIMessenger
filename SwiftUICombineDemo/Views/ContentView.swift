//
//  ContentView.swift
//  SwiftUICombineDemo
//
//  Created by Prateek on 24/09/20.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var viewModel = ChatViewModel()
    @State private var showActionSheet = false

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
//                    Color.clear.frame(height: 10)
                    LazyVStack {
                        ForEach(viewModel.messages) { message in
                            MessageCellView(message: message,
                                            isPreviousMessageFromSameUser: viewModel.isPreviousMessageSenderSame(ofMessage: message),
                                            isNextMessageFromSameUser: viewModel.isNextMessageSenderSame(ofMessage: message))
                        }
                    }
                    Color.clear.frame(height: 20)
                }
                .background(Color(red: 0.92, green: 0.92, blue: 0.92, opacity: 1))
                .onTapGesture {
                    UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.endEditing(true)
                }

                BottomContentView(showActionSheet: $showActionSheet, viewModel: viewModel)
            }
            .animation(.easeInOut)
            .actionSheet(isPresented: $showActionSheet) {
                ActionSheet(title: Text(viewModel.actionSheetTitle), buttons: actionSheetButtons())
            }
            .navigationBarTitle(Text(viewModel.appState.rawValue), displayMode: .inline)
        }
    }

    private func actionSheetButtons() -> [ActionSheet.Button] {
        var buttons = [ActionSheet.Button]()
        switch viewModel.appState {
        case .inactive:
            buttons = [
                .default(Text("Host Chat"), action: {
                    self.viewModel.startAdvertising()
                }),
                .default(Text("Join chat"), action: {
                    self.viewModel.startBrowsing()
                })
            ]
        default:
            buttons = [
                .default(Text("Disconnect"), action: {
                    self.viewModel.disconnect()
                })
            ]
        }
        buttons.append(.cancel(Text("Cancel")))
        return buttons
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

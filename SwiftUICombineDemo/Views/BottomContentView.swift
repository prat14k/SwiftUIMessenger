//
//  BottomContentView.swift
//  SwiftUICombineDemo
//
//  Created by Prateek on 25/09/20.
//

import SwiftUI

struct BottomContentView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Binding var showActionSheet: Bool
    @ObservedObject var viewModel: ChatViewModel

    var body: some View {
        HStack {
            Button {
                showActionSheet = true
            } label: {
                Image(systemName: "square.and.arrow.up")
            }.padding(.horizontal)

            TextField(viewModel.appState.isConnected ? "Type Message" : "Inactive", text: $viewModel.newMessageText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disabled(!viewModel.appState.isConnected)

            Button {
                viewModel.clear()
            } label: {
                Image(systemName: "xmark.circle")
            }

            Button {
                viewModel.send()
            } label: {
                Image(systemName: "paperplane")
            }
            .padding(.horizontal)
            .disabled(!viewModel.appState.isConnected)

        }
        .padding()
        .background(colorScheme == .dark ? Color.black : .white)
//        .offset(y: viewModel.keyboardOffset)
//        .animation(.easeInOut(duration: viewModel.keyboardAnimationDuration))
    }
}

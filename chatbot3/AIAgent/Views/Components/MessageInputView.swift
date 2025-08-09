//
//  MessageInputView.swift
//  AIAgent
//
//  Created by Developer on 01.01.2023.
//

import SwiftUI

// Mesaj giriş alanı görünümü
struct MessageInputView: View {
    @EnvironmentObject var appSettings: AppSettings
    @ObservedObject var viewModel: ChatViewModel
    @State private var showingSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Ayarlar çubuğu
            if showingSettings {
                settingsBar
            }
            
            // Mesaj giriş alanı
            HStack(spacing: 12) {
                // Mesaj yazma alanı
                TextField("Mesajınızı yazın...", text: $viewModel.inputMessage)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .disabled(viewModel.isProcessing)
                
                // Ayarlar butonu
                Button(action: {
                    withAnimation {
                        showingSettings.toggle()
                    }
                }) {
                    Image(systemName: "gear")
                        .font(.system(size: 20))
                        .foregroundColor(appSettings.currentTheme.primaryColor)
                        .frame(width: 40, height: 40)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
                
                // Gönder butonu
                Button(action: {
                    Task {
                        await viewModel.sendMessage()
                    }
                }) {
                    Image(systemName: viewModel.isProcessing ? "hourglass" : "arrow.up")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(appSettings.currentTheme.primaryColor)
                        .clipShape(Circle())
                }
                .disabled(viewModel.inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isProcessing)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.systemGray5)),
            alignment: .top
        )
    }
    
    // Ayarlar çubuğu
    private var settingsBar: some View {
        HStack(spacing: 16) {
            // Web arama açma/kapatma
            Toggle(isOn: $viewModel.webSearchEnabled) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("Web Arama")
                        .font(.caption)
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: appSettings.currentTheme.primaryColor))
            
            // Memory açma/kapatma
            Toggle(isOn: $viewModel.memoryEnabled) {
                HStack {
                    Image(systemName: "brain")
                    Text("Hafıza")
                        .font(.caption)
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: appSettings.currentTheme.primaryColor))
            
            // Geçmişi temizleme
            Button(action: {
                viewModel.clearMemory()
            }) {
                HStack {
                    Image(systemName: "trash")
                    Text("Geçmişi Temizle")
                        .font(.caption)
                }
                .foregroundColor(.red)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
}

// Önizleme
struct MessageInputView_Previews: PreviewProvider {
    static var previews: some View {
        MessageInputView(viewModel: ChatViewModel())
            .environmentObject(AppSettings())
            .previewLayout(.sizeThatFits)
    }
}
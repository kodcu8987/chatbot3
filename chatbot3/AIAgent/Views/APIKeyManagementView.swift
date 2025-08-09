//
//  APIKeyManagementView.swift
//  AIAgent
//
//  Created by Developer on 01.01.2023.
//

import SwiftUI

// API anahtarları yönetim ekranı
struct APIKeyManagementView: View {
    @EnvironmentObject var appSettings: AppSettings
    @StateObject private var viewModel = APIKeyViewModel()
    @State private var showingAddKey = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Ana liste
                List {
                    ForEach(viewModel.apiKeys) { keyItem in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(keyItem.serviceType.rawValue)
                                    .font(.headline)
                                
                                Text(maskAPIKey(keyItem.key))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Silme butonu
                            Button(action: {
                                viewModel.deleteAPIKey(keyItem.serviceType)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(InsetGroupedListStyle())
                
                // Boş durum görünümü
                if viewModel.apiKeys.isEmpty && !viewModel.isLoading {
                    VStack(spacing: 16) {
                        Image(systemName: "key.fill")
                            .font(.system(size: 50))
                            .foregroundColor(appSettings.currentTheme.primaryColor)
                        
                        Text("Henüz API anahtarı eklenmemiş")
                            .font(.headline)
                        
                        Text("AI servislerini kullanabilmek için API anahtarı eklemelisiniz.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            showingAddKey = true
                        }) {
                            Text("API Anahtarı Ekle")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(appSettings.currentTheme.primaryColor)
                                .cornerRadius(10)
                        }
                    }
                }
                
                // Yükleniyor göstergesi
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
            .navigationTitle("API Anahtarlarım")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddKey = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddKey) {
                AddAPIKeyView(viewModel: viewModel)
            }
            .onAppear {
                viewModel.loadAPIKeys()
            }
            .overlay(
                // Hata mesajı
                viewModel.errorMessage.map { errorMessage in
                    VStack {
                        Spacer()
                        Text(errorMessage)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                            .padding()
                    }
                }
            )
            .overlay(
                // Başarı mesajı
                viewModel.successMessage.map { successMessage in
                    VStack {
                        Spacer()
                        Text(successMessage)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                            .padding()
                    }
                }
            )
        }
    }
    
    // API anahtarını maskeleme
    private func maskAPIKey(_ key: String) -> String {
        guard key.count > 8 else { return "****" }
        return String(key.prefix(4)) + "****" + String(key.suffix(4))
    }
}

// API anahtarı ekleme ekranı
struct AddAPIKeyView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appSettings: AppSettings
    @ObservedObject var viewModel: APIKeyViewModel
    
    @State private var selectedService = AIServiceType.openAI
    @State private var apiKey = ""
    @State private var isValidating = false
    
    var body: some View {
        NavigationView {
            Form {
                // Servis seçimi
                Section(header: Text("AI Servisi")) {
                    Picker("Servis", selection: $selectedService) {
                        ForEach(AIServiceType.allCases, id: \.self) { service in
                            Text(service.rawValue).tag(service)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // API anahtarı girişi
                Section(header: Text("API Anahtarı")) {
                    SecureField("API Anahtarını Girin", text: $apiKey)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                // Servis bilgileri
                Section(header: Text("Bilgi")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(serviceInfo)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Link("API Anahtarı Nasıl Alınır?", destination: serviceHelpURL)
                            .font(.caption)
                    }
                }
                
                // Ekle butonu
                Section {
                    Button(action: addAPIKey) {
                        if isValidating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Ekle")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .background(isFormValid ? appSettings.currentTheme.primaryColor : Color.gray)
                    .cornerRadius(8)
                    .disabled(!isFormValid || isValidating)
                }
            }
            .navigationTitle("API Anahtarı Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    // Form geçerli mi kontrolü
    private var isFormValid: Bool {
        !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // Servis bilgisi
    private var serviceInfo: String {
        switch selectedService {
        case .openAI:
            return "OpenAI API anahtarınızı OpenAI hesabınızdan alabilirsiniz. API anahtarı, GPT-4o, GPT-4o-mini ve GPT-3.5-turbo modellerine erişim sağlar."
        case .openRouter:
            return "OpenRouter API anahtarınızı OpenRouter hesabınızdan alabilirsiniz. API anahtarı, GPT-4, DeepSeek Chat, Claude 3 ve Llama 3 gibi çeşitli modellere erişim sağlar."
        }
    }
    
    // Servis yardım URL'si
    private var serviceHelpURL: URL {
        switch selectedService {
        case .openAI:
            return URL(string: "https://platform.openai.com/account/api-keys")!
        case .openRouter:
            return URL(string: "https://openrouter.ai/keys")!
        }
    }
    
    // API anahtarı ekleme
    private func addAPIKey() {
        isValidating = true
        
        Task {
            await viewModel.addAPIKey(serviceType: selectedService, key: apiKey)
            isValidating = false
            
            // Başarılı ise kapat
            if viewModel.errorMessage == nil {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

// Önizleme
struct APIKeyManagementView_Previews: PreviewProvider {
    static var previews: some View {
        APIKeyManagementView()
            .environmentObject(AppSettings())
    }
}
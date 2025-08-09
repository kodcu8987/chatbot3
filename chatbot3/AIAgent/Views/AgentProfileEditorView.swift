//
//  AgentProfileEditorView.swift
//  AIAgent
//
//  Created by Developer on 01.01.2023.
//

import SwiftUI

// Düzenleme modu
enum ProfileEditMode {
    case create
    case edit(AgentProfile)
}

// Agent profil düzenleyici görünümü
struct AgentProfileEditorView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appSettings: AppSettings
    @ObservedObject var viewModel: AgentProfileViewModel
    let mode: ProfileEditMode
    
    @State private var name = ""
    @State private var description = ""
    @State private var serviceType = AIServiceType.openAI
    @State private var modelId = ""
    @State private var systemPrompt = ""
    @State private var memoryEnabled = true
    @State private var webSearchEnabled = true
    @State private var showingServiceSelector = false
    @State private var showingModelSelector = false
    
    init(viewModel: AgentProfileViewModel, mode: ProfileEditMode) {
        self.viewModel = viewModel
        self.mode = mode
        
        // Düzenleme modunda ise mevcut değerleri yükle
        if case .edit(let profile) = mode {
            _name = State(initialValue: profile.name)
            _description = State(initialValue: profile.description)
            _serviceType = State(initialValue: profile.serviceType)
            _modelId = State(initialValue: profile.modelId)
            _systemPrompt = State(initialValue: profile.systemPrompt)
            _memoryEnabled = State(initialValue: profile.memoryEnabled)
            _webSearchEnabled = State(initialValue: profile.webSearchEnabled)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Temel bilgiler
                Section(header: Text("Temel Bilgiler")) {
                    TextField("Profil Adı", text: $name)
                    
                    TextField("Açıklama", text: $description)
                        .lineLimit(3)
                }
                
                // AI servisi ve model seçimi
                Section(header: Text("AI Servisi ve Model")) {
                    // Servis seçimi
                    Button(action: {
                        showingServiceSelector = true
                    }) {
                        HStack {
                            Text("AI Servisi")
                            Spacer()
                            Text(serviceType.rawValue)
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Model seçimi
                    Button(action: {
                        showingModelSelector = true
                    }) {
                        HStack {
                            Text("Model")
                            Spacer()
                            Text(modelId.isEmpty ? "Seçilmedi" : modelId)
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Sistem promptu
                Section(header: Text("Sistem Promptu")) {
                    TextEditor(text: $systemPrompt)
                        .frame(minHeight: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                
                // Özellikler
                Section(header: Text("Özellikler")) {
                    Toggle("Hafıza", isOn: $memoryEnabled)
                    Toggle("Web Arama", isOn: $webSearchEnabled)
                }
                
                // Kaydet butonu
                Section {
                    Button(action: saveProfile) {
                        Text("Kaydet")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(isFormValid ? appSettings.currentTheme.primaryColor : Color.gray)
                            .cornerRadius(8)
                    }
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingServiceSelector) {
                ServiceSelectorView(selectedService: $serviceType)
            }
            .sheet(isPresented: $showingModelSelector) {
                ModelSelectorView(serviceType: serviceType, selectedModel: $modelId)
            }
        }
    }
    
    // Form geçerli mi kontrolü
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !modelId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // Navigasyon başlığı
    private var navigationTitle: String {
        switch mode {
        case .create:
            return "Yeni Agent Profili"
        case .edit:
            return "Profili Düzenle"
        }
    }
    
    // Profili kaydet
    private func saveProfile() {
        let profile = AgentProfile(
            id: (mode == .create) ? UUID().uuidString : (if case .edit(let profile) = mode { profile.id } else { UUID().uuidString }),
            name: name,
            description: description,
            serviceType: serviceType,
            modelId: modelId,
            systemPrompt: systemPrompt,
            memoryEnabled: memoryEnabled,
            webSearchEnabled: webSearchEnabled
        )
        
        switch mode {
        case .create:
            viewModel.addProfile(profile)
        case .edit:
            viewModel.updateProfile(profile)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

// Servis seçici görünümü
struct ServiceSelectorView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appSettings: AppSettings
    @Binding var selectedService: AIServiceType
    
    var body: some View {
        NavigationView {
            List {
                ForEach(AIServiceType.allCases, id: \.self) { service in
                    Button(action: {
                        selectedService = service
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Text(service.rawValue)
                                .font(.headline)
                            
                            Spacer()
                            
                            if selectedService == service {
                                Image(systemName: "checkmark")
                                    .foregroundColor(appSettings.currentTheme.primaryColor)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("AI Servisi Seçin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Kapat") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// Model seçici görünümü
struct ModelSelectorView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appSettings: AppSettings
    let serviceType: AIServiceType
    @Binding var selectedModel: String
    
    // Servis türüne göre modelleri getir
    private var availableModels: [AIModel] {
        switch serviceType {
        case .openAI:
            return [
                AIModel(id: "gpt-4o", name: "GPT-4o"),
                AIModel(id: "gpt-4o-mini", name: "GPT-4o Mini"),
                AIModel(id: "gpt-3.5-turbo", name: "GPT-3.5 Turbo")
            ]
        case .openRouter:
            return [
                AIModel(id: "gpt-4", name: "GPT-4"),
                AIModel(id: "deepseek-chat", name: "DeepSeek Chat"),
                AIModel(id: "claude-3-opus", name: "Claude 3 Opus"),
                AIModel(id: "claude-3-sonnet", name: "Claude 3 Sonnet"),
                AIModel(id: "llama-3-70b", name: "Llama 3 70B")
            ]
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(availableModels) { model in
                    Button(action: {
                        selectedModel = model.id
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(model.name)
                                    .font(.headline)
                                
                                Text(model.id)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if selectedModel == model.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(appSettings.currentTheme.primaryColor)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Model Seçin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Kapat") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// Önizleme
struct AgentProfileEditorView_Previews: PreviewProvider {
    static var previews: some View {
        AgentProfileEditorView(
            viewModel: AgentProfileViewModel(),
            mode: .create
        )
        .environmentObject(AppSettings())
    }
}
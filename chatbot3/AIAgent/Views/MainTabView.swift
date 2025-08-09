//
//  MainTabView.swift
//  AIAgent
//
//  Created by Developer on 01.01.2023.
//

import SwiftUI

// Ana sekme görünümü
struct MainTabView: View {
    @EnvironmentObject var appSettings: AppSettings
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Sohbet ekranı
            NavigationView {
                ChatView()
            }
            .tabItem {
                Label("Sohbet", systemImage: "message.fill")
            }
            .tag(0)
            
            // Agent profilleri ekranı
            NavigationView {
                AgentProfileListView()
            }
            .tabItem {
                Label("Profiller", systemImage: "person.fill")
            }
            .tag(1)
            
            // Ayarlar ekranı
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Label("Ayarlar", systemImage: "gear")
            }
            .tag(2)
        }
        .accentColor(appSettings.currentTheme.primaryColor)
    }
}

// Agent profil listesi görünümü
struct AgentProfileListView: View {
    @EnvironmentObject var appSettings: AppSettings
    @StateObject private var viewModel = AgentProfileViewModel()
    @State private var showingCreateProfile = false
    @State private var editingProfile: AgentProfile? = nil
    
    var body: some View {
        ZStack {
            // Ana liste
            List {
                ForEach(viewModel.profiles) { profile in
                    Button(action: {
                        editingProfile = profile
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(profile.name)
                                    .font(.headline)
                                
                                Text(profile.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                                
                                HStack(spacing: 8) {
                                    // Servis ve model bilgisi
                                    Label(
                                        profile.serviceType.rawValue,
                                        systemImage: "server.rack"
                                    )
                                    .font(.caption2)
                                    
                                    Label(
                                        profile.modelId,
                                        systemImage: "cpu"
                                    )
                                    .font(.caption2)
                                    
                                    // Hafıza durumu
                                    if profile.memoryEnabled {
                                        Label(
                                            "Hafıza",
                                            systemImage: "brain"
                                        )
                                        .font(.caption2)
                                    }
                                    
                                    // Web arama durumu
                                    if profile.webSearchEnabled {
                                        Label(
                                            "Web Arama",
                                            systemImage: "magnifyingglass"
                                        )
                                        .font(.caption2)
                                    }
                                }
                                .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(.primary)
                }
                .onDelete { indexSet in
                    viewModel.deleteProfile(at: indexSet)
                }
            }
            .listStyle(InsetGroupedListStyle())
            
            // Boş durum görünümü
            if viewModel.profiles.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 50))
                        .foregroundColor(appSettings.currentTheme.primaryColor)
                    
                    Text("Henüz agent profili oluşturulmamış")
                        .font(.headline)
                    
                    Text("Farklı görevler için özelleştirilmiş agent profilleri oluşturabilirsiniz.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        showingCreateProfile = true
                    }) {
                        Text("Profil Oluştur")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(appSettings.currentTheme.primaryColor)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .navigationTitle("Agent Profilleri")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingCreateProfile = true
                }) {
                    Image(systemName: "plus")
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
        }
        .sheet(isPresented: $showingCreateProfile) {
            AgentProfileEditorView(viewModel: viewModel, mode: .create)
        }
        .sheet(item: $editingProfile) { profile in
            AgentProfileEditorView(viewModel: viewModel, mode: .edit(profile))
        }
        .onAppear {
            viewModel.loadProfiles()
        }
    }
}

// Ayarlar görünümü
struct SettingsView: View {
    @EnvironmentObject var appSettings: AppSettings
    @State private var showingResetConfirmation = false
    
    var body: some View {
        List {
            // API anahtarları
            Section(header: Text("API Anahtarları")) {
                NavigationLink(destination: APIKeyManagementView()) {
                    Label(
                        "API Anahtarlarım",
                        systemImage: "key.fill"
                    )
                }
            }
            
            // Tema ayarları
            Section(header: Text("Görünüm")) {
                Picker("Tema", selection: $appSettings.currentTheme) {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        HStack {
                            Circle()
                                .fill(theme.primaryColor)
                                .frame(width: 20, height: 20)
                            Text(theme.localizedName)
                        }
                        .tag(theme)
                    }
                }
            }
            
            // Uygulama bilgileri
            Section(header: Text("Uygulama Bilgileri")) {
                HStack {
                    Text("Versiyon")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Minimum iOS")
                    Spacer()
                    Text("15.0")
                        .foregroundColor(.secondary)
                }
            }
            
            // Sıfırlama
            Section {
                Button(action: {
                    showingResetConfirmation = true
                }) {
                    HStack {
                        Spacer()
                        Text("Tüm Verileri Sıfırla")
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Ayarlar")
        .alert("Tüm Verileri Sıfırla", isPresented: $showingResetConfirmation) {
            Button("İptal", role: .cancel) { }
            Button("Sıfırla", role: .destructive) {
                resetAllData()
            }
        } message: {
            Text("Tüm API anahtarları, agent profilleri ve sohbet geçmişi silinecektir. Bu işlem geri alınamaz.")
        }
    }
    
    // Tüm verileri sıfırlama
    private func resetAllData() {
        // API anahtarlarını sil
        let apiKeyViewModel = APIKeyViewModel()
        apiKeyViewModel.deleteAllAPIKeys()
        
        // Agent profillerini sıfırla
        let profileViewModel = AgentProfileViewModel()
        profileViewModel.resetProfiles()
        
        // Belleği temizle
        MemoryManager.shared.clearAllMemory()
    }
}

// Tema için yerelleştirilmiş isimler
extension AppTheme {
    var localizedName: String {
        switch self {
        case .blue:
            return "Mavi"
        case .green:
            return "Yeşil"
        case .purple:
            return "Mor"
        case .orange:
            return "Turuncu"
        }
    }
}

// Görev türü için simge adı
extension TaskType {
    var iconName: String {
        switch self {
        case .general:
            return "bubble.left.and.bubble.right"
        case .coding:
            return "chevron.left.forwardslash.chevron.right"
        case .research:
            return "magnifyingglass"
        case .translation:
            return "globe"
        case .textAnalysis:
            return "doc.text.magnifyingglass"
        }
    }
    
    var localizedName: String {
        switch self {
        case .general:
            return "Genel"
        case .coding:
            return "Kodlama"
        case .research:
            return "Araştırma"
        case .translation:
            return "Çeviri"
        case .textAnalysis:
            return "Metin Analizi"
        }
    }
}

// Önizleme
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AppSettings())
    }
}
//
//  ChatView.swift
//  AIAgent
//
//  Created by Developer on 01.01.2023.
//

import SwiftUI

// Ana sohbet ekranı
struct ChatView: View {
    @EnvironmentObject var appSettings: AppSettings
    @StateObject var viewModel = ChatViewModel()
    @State private var showingProfileSelector = false
    @State private var showingTaskTypeSelector = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Üst bilgi çubuğu
            headerView
            
            // Mesaj listesi
            ScrollViewReader { scrollView in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.messages) { message in
                            MessageBubbleView(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal)
                }
                .onChange(of: viewModel.messages) { _ in
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Mesaj giriş alanı
            MessageInputView(viewModel: viewModel)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingProfileSelector) {
            AgentProfileSelectorView(selectedProfile: $viewModel.selectedProfile)
        }
        .sheet(isPresented: $showingTaskTypeSelector) {
            TaskTypeSelectorView(selectedTaskType: $viewModel.taskType)
        }
        .onAppear {
            viewModel.loadMessages()
        }
    }
    
    // Üst bilgi çubuğu
    private var headerView: some View {
        HStack {
            // Profil seçici
            Button(action: {
                showingProfileSelector = true
            }) {
                HStack {
                    Text(viewModel.selectedProfile?.name ?? "Profil Seç")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            Spacer()
            
            // Görev türü seçici
            Button(action: {
                showingTaskTypeSelector = true
            }) {
                HStack {
                    Text(viewModel.taskType.localizedName)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            // Yeni sohbet butonu
            Button(action: {
                viewModel.startNewChat()
            }) {
                Image(systemName: "plus.square")
                    .font(.headline)
                    .foregroundColor(appSettings.currentTheme.primaryColor)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.systemGray5)),
            alignment: .bottom
        )
    }
}

// Agent profil seçici görünümü
struct AgentProfileSelectorView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appSettings: AppSettings
    @StateObject private var viewModel = AgentProfileViewModel()
    @Binding var selectedProfile: AgentProfile?
    @State private var showingCreateProfile = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.profiles) { profile in
                    Button(action: {
                        selectedProfile = profile
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(profile.name)
                                    .font(.headline)
                                
                                Text(profile.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                            
                            Spacer()
                            
                            if selectedProfile?.id == profile.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(appSettings.currentTheme.primaryColor)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
                .onDelete { indexSet in
                    viewModel.deleteProfile(at: indexSet)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Agent Profilleri")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Kapat") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCreateProfile = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreateProfile) {
            AgentProfileEditorView(viewModel: viewModel, mode: .create)
        }
        .onAppear {
            viewModel.loadProfiles()
        }
    }
}

// Görev türü seçici görünümü
struct TaskTypeSelectorView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appSettings: AppSettings
    @Binding var selectedTaskType: TaskType
    
    var body: some View {
        NavigationView {
            List {
                ForEach(TaskType.allCases, id: \.self) { taskType in
                    Button(action: {
                        selectedTaskType = taskType
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: taskType.iconName)
                                .foregroundColor(appSettings.currentTheme.primaryColor)
                                .frame(width: 30)
                            
                            Text(taskType.localizedName)
                                .font(.headline)
                            
                            Spacer()
                            
                            if selectedTaskType == taskType {
                                Image(systemName: "checkmark")
                                    .foregroundColor(appSettings.currentTheme.primaryColor)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Görev Türü Seçin")
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
struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
            .environmentObject(AppSettings())
    }
}
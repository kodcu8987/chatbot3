//
//  ChatViewModel.swift
//  AIAgent
//
//  Created by Developer on 01.01.2023.
//

import Foundation
import Combine
import SwiftUI

// Sohbet ekranı için ViewModel
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var inputMessage: String = ""
    @Published var isProcessing: Bool = false
    @Published var currentTask: Task?
    @Published var selectedAgentProfile: AgentProfile?
    @Published var selectedTaskType: TaskType = .general
    @Published var webSearchEnabled: Bool = true
    @Published var memoryEnabled: Bool = true
    @Published var errorMessage: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // AI servisinin işlem durumunu takip et
        AIServiceManager.shared.$isProcessing
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isProcessing in
                self?.isProcessing = isProcessing
            }
            .store(in: &cancellables)
        
        // AI servisinin hata durumunu takip et
        AIServiceManager.shared.$currentError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.errorMessage = nil
                }
            }
            .store(in: &cancellables)
    }
    
    // Mesaj gönderme
    func sendMessage() async {
        guard !inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard let agentProfile = selectedAgentProfile else {
            errorMessage = "Lütfen bir agent profili seçin."
            return
        }
        
        let userMessage = Message(type: .user, content: inputMessage)
        
        // Kullanıcı mesajını ekle
        await MainActor.run {
            messages.append(userMessage)
            inputMessage = ""
            isProcessing = true
        }
        
        // Görev oluştur veya mevcut göreve mesaj ekle
        if currentTask == nil {
            let newTask = Task(
                agentProfileId: agentProfile.id,
                type: selectedTaskType,
                title: userMessage.content.prefix(50).appending(userMessage.content.count > 50 ? "..." : "")
            )
            await MainActor.run {
                currentTask = newTask
            }
        }
        
        guard var task = currentTask else { return }
        task.addMessage(userMessage)
        
        // Agent profilinin ayarlarını güncelle
        var updatedProfile = agentProfile
        updatedProfile.memoryEnabled = memoryEnabled
        updatedProfile.webSearchEnabled = webSearchEnabled
        
        do {
            // AI yanıtını al
            let assistantMessage = try await AIServiceManager.shared.sendMessage(
                message: userMessage.content,
                agentProfile: updatedProfile,
                task: task
            )
            
            // Yanıtı ekle
            await MainActor.run {
                messages.append(assistantMessage)
                task.addMessage(assistantMessage)
                currentTask = task
                MemoryManager.shared.saveTask(task)
                isProcessing = false
            }
            
        } catch {
            // Hata mesajı oluştur
            let errorMessage = AIServiceManager.shared.createErrorMessage(error: error)
            
            await MainActor.run {
                messages.append(errorMessage)
                task.addMessage(errorMessage)
                currentTask = task
                MemoryManager.shared.saveTask(task)
                isProcessing = false
            }
        }
    }
    
    // Yeni sohbet başlatma
    func startNewChat() {
        messages = []
        currentTask = nil
        errorMessage = nil
    }
    
    // Hafızayı temizleme
    func clearMemory() {
        startNewChat()
        if let agentProfile = selectedAgentProfile {
            MemoryManager.shared.clearTasks(for: agentProfile.id)
        }
    }
    
    // Agent profilini değiştirme
    func changeAgentProfile(_ profile: AgentProfile) {
        selectedAgentProfile = profile
        webSearchEnabled = profile.webSearchEnabled
        memoryEnabled = profile.memoryEnabled
        startNewChat()
    }
}
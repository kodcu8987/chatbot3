//
//  AIService.swift
//  AIAgent
//
//  Created by Developer on 01.01.2023.
//

import Foundation
import Combine

// AI servisleri için ana servis
class AIServiceManager: ObservableObject {
    static let shared = AIServiceManager()
    
    @Published var isProcessing = false
    @Published var currentError: AIError? = nil
    
    private init() {}
    
    // Mesaj gönderme
    func sendMessage(message: String, agentProfile: AgentProfile, task: Task) async throws -> Message {
        guard let serviceType = agentProfile.aiServiceType,
              let model = agentProfile.getModel() else {
            throw AIError.unknown("Geçersiz servis veya model")
        }
        
        isProcessing = true
        defer { isProcessing = false }
        
        // Web araması yapılacak mı kontrol et
        var webSearchResults: [WebSearchResult]? = nil
        if agentProfile.webSearchEnabled && WebSearchService.shared.shouldTriggerSearch(for: message) {
            do {
                webSearchResults = try await WebSearchService.shared.search(query: message)
            } catch {
                // Web araması başarısız olursa, sadece AI yanıtı ile devam et
                print("Web araması başarısız: \(error)")
            }
        }
        
        // Memory kullanılacak mı kontrol et
        var memory: [Message]? = nil
        if agentProfile.memoryEnabled {
            memory = task.messages
        }
        
        do {
            // AI servisine istek gönder
            let response = try await serviceType.service.sendMessage(
                message,
                model: model,
                systemPrompt: agentProfile.systemPrompt,
                memory: memory
            )
            
            // Web arama sonuçları varsa, yanıta ekle
            var finalResponse = response
            if let webSearchResults = webSearchResults, !webSearchResults.isEmpty {
                let searchSummary = WebSearchService.shared.summarizeSearchResults(webSearchResults)
                finalResponse = "\(searchSummary)\n\nAI Yanıtı:\n\(response)"
            }
            
            // Yanıtı mesaj olarak döndür
            return Message(type: .assistant, content: finalResponse, webSearchResults: webSearchResults)
            
        } catch let error as AIError {
            currentError = error
            throw error
        } catch {
            let aiError = AIError.unknown(error.localizedDescription)
            currentError = aiError
            throw aiError
        }
    }
    
    // API anahtarını doğrulama
    func validateAPIKey(_ key: String, for serviceType: AIServiceType) async throws -> Bool {
        do {
            return try await serviceType.service.validateAPIKey(key)
        } catch {
            throw AIError.invalidAPIKey
        }
    }
    
    // Hata mesajı oluşturma
    func createErrorMessage(error: Error) -> Message {
        let errorMessage: String
        
        if let aiError = error as? AIError {
            errorMessage = aiError.localizedDescription
        } else if let webSearchError = error as? WebSearchError {
            errorMessage = webSearchError.localizedDescription
        } else {
            errorMessage = "Bilinmeyen bir hata oluştu: \(error.localizedDescription)"
        }
        
        return Message(type: .error, content: errorMessage)
    }
}
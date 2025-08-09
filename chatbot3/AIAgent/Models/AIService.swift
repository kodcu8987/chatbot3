//
//  AIService.swift
//  AIAgent
//
//  Created by Developer on 01.01.2023.
//

import Foundation

// AI Servisi protokolü - Yeni servisler eklemek için bu protokolü uygulayın
protocol AIServiceProtocol {
    var id: String { get }
    var name: String { get }
    var models: [AIModel] { get }
    var apiKeyName: String { get }
    
    func validateAPIKey(_ key: String) async throws -> Bool
    func sendMessage(_ message: String, model: AIModel, systemPrompt: String?, memory: [Message]?) async throws -> String
}

// AI Servisi türleri
enum AIServiceType: String, CaseIterable, Identifiable {
    case openAI = "OpenAI"
    case openRouter = "OpenRouter"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .openAI: return "OpenAI"
        case .openRouter: return "OpenRouter"
        }
    }
    
    var service: AIServiceProtocol {
        switch self {
        case .openAI: return OpenAIService()
        case .openRouter: return OpenRouterService()
        }
    }
}

// AI Modeli
struct AIModel: Identifiable, Hashable {
    let id: String
    let name: String
    let serviceType: AIServiceType
    let maxTokens: Int
    
    static func == (lhs: AIModel, rhs: AIModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// OpenAI Servisi
class OpenAIService: AIServiceProtocol {
    var id: String { "openai" }
    var name: String { "OpenAI" }
    var apiKeyName: String { "OPENAI_API_KEY" }
    
    var models: [AIModel] {
        [
            AIModel(id: "gpt-4o", name: "GPT-4o", serviceType: .openAI, maxTokens: 8192),
            AIModel(id: "gpt-4o-mini", name: "GPT-4o Mini", serviceType: .openAI, maxTokens: 8192),
            AIModel(id: "gpt-3.5-turbo", name: "GPT-3.5 Turbo", serviceType: .openAI, maxTokens: 4096)
        ]
    }
    
    func validateAPIKey(_ key: String) async throws -> Bool {
        // Gerçek uygulamada API anahtarını doğrulama kodu
        guard !key.isEmpty else { throw AIError.invalidAPIKey }
        return true
    }
    
    func sendMessage(_ message: String, model: AIModel, systemPrompt: String?, memory: [Message]?) async throws -> String {
        // Gerçek uygulamada OpenAI API'ye istek gönderme kodu
        guard let apiKey = KeychainManager.shared.getAPIKey(for: apiKeyName) else {
            throw AIError.missingAPIKey
        }
        
        // API isteği oluşturma ve gönderme kodu burada olacak
        // Bu örnek için basit bir yanıt döndürüyoruz
        return "OpenAI yanıtı: \(message)"
    }
}

// OpenRouter Servisi
class OpenRouterService: AIServiceProtocol {
    var id: String { "openrouter" }
    var name: String { "OpenRouter" }
    var apiKeyName: String { "OPENROUTER_API_KEY" }
    
    var models: [AIModel] {
        [
            AIModel(id: "gpt-4", name: "GPT-4", serviceType: .openRouter, maxTokens: 8192),
            AIModel(id: "deepseek-chat", name: "DeepSeek Chat", serviceType: .openRouter, maxTokens: 4096)
        ]
    }
    
    func validateAPIKey(_ key: String) async throws -> Bool {
        // Gerçek uygulamada API anahtarını doğrulama kodu
        guard !key.isEmpty else { throw AIError.invalidAPIKey }
        return true
    }
    
    func sendMessage(_ message: String, model: AIModel, systemPrompt: String?, memory: [Message]?) async throws -> String {
        // Gerçek uygulamada OpenRouter API'ye istek gönderme kodu
        guard let apiKey = KeychainManager.shared.getAPIKey(for: apiKeyName) else {
            throw AIError.missingAPIKey
        }
        
        // API isteği oluşturma ve gönderme kodu burada olacak
        // Bu örnek için basit bir yanıt döndürüyoruz
        return "OpenRouter yanıtı: \(message)"
    }
}

// AI ile ilgili hatalar
enum AIError: Error {
    case invalidAPIKey
    case missingAPIKey
    case quotaExceeded
    case networkError
    case invalidResponse
    case unknown(String)
    
    var localizedDescription: String {
        switch self {
        case .invalidAPIKey:
            return "Geçersiz API anahtarı."
        case .missingAPIKey:
            return "API anahtarı bulunamadı. Lütfen ayarlardan bir API anahtarı ekleyin."
        case .quotaExceeded:
            return "API kotanız doldu. Lütfen daha sonra tekrar deneyin veya farklı bir API anahtarı kullanın."
        case .networkError:
            return "Ağ hatası. Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin."
        case .invalidResponse:
            return "Geçersiz yanıt alındı. Lütfen tekrar deneyin."
        case .unknown(let message):
            return "Bilinmeyen hata: \(message)"
        }
    }
}
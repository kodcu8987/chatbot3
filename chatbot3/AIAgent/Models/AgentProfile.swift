//
//  AgentProfile.swift
//  AIAgent
//
//  Created by Developer on 01.01.2023.
//

import Foundation

// Agent Profili
struct AgentProfile: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var description: String
    var serviceType: String // AIServiceType.rawValue olarak saklanır
    var modelId: String
    var systemPrompt: String
    var memoryEnabled: Bool
    var webSearchEnabled: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), name: String, description: String, serviceType: AIServiceType, modelId: String, systemPrompt: String, memoryEnabled: Bool = true, webSearchEnabled: Bool = true) {
        self.id = id
        self.name = name
        self.description = description
        self.serviceType = serviceType.rawValue
        self.modelId = modelId
        self.systemPrompt = systemPrompt
        self.memoryEnabled = memoryEnabled
        self.webSearchEnabled = webSearchEnabled
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // Servis türünü AIServiceType olarak almak için
    var aiServiceType: AIServiceType? {
        return AIServiceType(rawValue: serviceType)
    }
    
    // Modeli almak için
    func getModel() -> AIModel? {
        guard let serviceType = aiServiceType else { return nil }
        return serviceType.service.models.first(where: { $0.id == modelId })
    }
    
    // Profili güncellemek için
    mutating func update(name: String? = nil, description: String? = nil, serviceType: AIServiceType? = nil, modelId: String? = nil, systemPrompt: String? = nil, memoryEnabled: Bool? = nil, webSearchEnabled: Bool? = nil) {
        if let name = name { self.name = name }
        if let description = description { self.description = description }
        if let serviceType = serviceType { self.serviceType = serviceType.rawValue }
        if let modelId = modelId { self.modelId = modelId }
        if let systemPrompt = systemPrompt { self.systemPrompt = systemPrompt }
        if let memoryEnabled = memoryEnabled { self.memoryEnabled = memoryEnabled }
        if let webSearchEnabled = webSearchEnabled { self.webSearchEnabled = webSearchEnabled }
        self.updatedAt = Date()
    }
    
    // Önceden tanımlanmış agent profilleri
    static let presetProfiles: [AgentProfile] = [
        AgentProfile(
            name: "Kodlama Asistanı",
            description: "Programlama ve kod yazma konusunda yardımcı olur",
            serviceType: .openAI,
            modelId: "gpt-4o",
            systemPrompt: "Sen deneyimli bir yazılım geliştirme uzmanısın. Kullanıcıya kod yazma, hata ayıklama ve programlama kavramlarını açıklama konusunda yardımcı ol. Kod örnekleri ver ve açıkla."
        ),
        AgentProfile(
            name: "Araştırma Botu",
            description: "Detaylı araştırma ve bilgi toplama için",
            serviceType: .openAI,
            modelId: "gpt-4o",
            systemPrompt: "Sen bir araştırma asistanısın. Kullanıcının sorularına kapsamlı ve doğru yanıtlar ver. Bilmediğin konularda tahmin yürütme, web aramasını kullan.",
            webSearchEnabled: true
        ),
        AgentProfile(
            name: "Çeviri Botu",
            description: "Metinleri farklı dillere çevirir",
            serviceType: .openRouter,
            modelId: "gpt-4",
            systemPrompt: "Sen profesyonel bir çevirmensin. Kullanıcının gönderdiği metni istediği dile doğru ve akıcı bir şekilde çevir. Çevirinin doğal ve hedef dilin kültürüne uygun olmasına dikkat et.",
            memoryEnabled: false,
            webSearchEnabled: false
        )
    ]
}

// Görev Türü
enum TaskType: String, CaseIterable, Identifiable {
    case general = "Genel"
    case coding = "Kodlama"
    case research = "Araştırma"
    case translation = "Çeviri"
    case textAnalysis = "Metin Analizi"
    
    var id: String { self.rawValue }
    
    var description: String {
        switch self {
        case .general: return "Genel amaçlı sohbet ve yardım"
        case .coding: return "Kod yazma ve programlama yardımı"
        case .research: return "Detaylı araştırma ve bilgi toplama"
        case .translation: return "Metinleri farklı dillere çevirme"
        case .textAnalysis: return "Metin analizi ve özetleme"
        }
    }
    
    var suggestedPrompt: String {
        switch self {
        case .general: return ""
        case .coding: return "Lütfen şu kodu yazabilir misin: "
        case .research: return "Şu konu hakkında detaylı bilgi almak istiyorum: "
        case .translation: return "Lütfen şu metni [dil] diline çevir: "
        case .textAnalysis: return "Lütfen şu metni analiz et ve özetle: "
        }
    }
}

// Görev (Conversation)
struct Task: Identifiable, Codable {
    var id: UUID
    var agentProfileId: UUID
    var type: String // TaskType.rawValue olarak saklanır
    var title: String
    var messages: [Message]
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), agentProfileId: UUID, type: TaskType, title: String, messages: [Message] = []) {
        self.id = id
        self.agentProfileId = agentProfileId
        self.type = type.rawValue
        self.title = title
        self.messages = messages
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // Görev türünü TaskType olarak almak için
    var taskType: TaskType? {
        return TaskType(rawValue: type)
    }
    
    // Yeni mesaj eklemek için
    mutating func addMessage(_ message: Message) {
        messages.append(message)
        self.updatedAt = Date()
    }
}
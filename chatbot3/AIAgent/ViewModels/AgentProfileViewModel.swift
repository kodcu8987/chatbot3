//
//  AgentProfileViewModel.swift
//  AIAgent
//
//  Created by Developer on 01.01.2023.
//

import Foundation
import Combine
import SwiftUI

// Agent profilleri yönetimi için ViewModel
class AgentProfileViewModel: ObservableObject {
    @Published var profiles: [AgentProfile] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    
    // Yeni profil oluşturma için geçici değişkenler
    @Published var newProfileName: String = ""
    @Published var newProfileDescription: String = ""
    @Published var newProfileServiceType: AIServiceType = .openAI
    @Published var newProfileModelId: String = ""
    @Published var newProfileSystemPrompt: String = ""
    @Published var newProfileMemoryEnabled: Bool = true
    @Published var newProfileWebSearchEnabled: Bool = true
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // AgentProfileService'den profilleri takip et
        AgentProfileService.shared.$profiles
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profiles in
                self?.profiles = profiles
            }
            .store(in: &cancellables)
    }
    
    // Profil ekleme
    func addProfile() {
        guard validateNewProfile() else { return }
        
        let newProfile = AgentProfile(
            name: newProfileName,
            description: newProfileDescription,
            serviceType: newProfileServiceType,
            modelId: newProfileModelId,
            systemPrompt: newProfileSystemPrompt,
            memoryEnabled: newProfileMemoryEnabled,
            webSearchEnabled: newProfileWebSearchEnabled
        )
        
        AgentProfileService.shared.addProfile(newProfile)
        resetNewProfileFields()
        successMessage = "Profil başarıyla eklendi."
    }
    
    // Profil güncelleme
    func updateProfile(_ profile: AgentProfile) {
        AgentProfileService.shared.updateProfile(profile)
        successMessage = "Profil başarıyla güncellendi."
    }
    
    // Profil silme
    func deleteProfile(id: UUID) {
        AgentProfileService.shared.deleteProfile(id: id)
        successMessage = "Profil başarıyla silindi."
    }
    
    // Tüm profilleri sıfırlama
    func resetProfiles() {
        AgentProfileService.shared.resetProfiles()
        successMessage = "Tüm profiller varsayılan değerlere sıfırlandı."
    }
    
    // Yeni profil alanlarını doğrulama
    private func validateNewProfile() -> Bool {
        if newProfileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Profil adı boş olamaz."
            return false
        }
        
        if newProfileModelId.isEmpty {
            errorMessage = "Lütfen bir model seçin."
            return false
        }
        
        if newProfileSystemPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Sistem promptu boş olamaz."
            return false
        }
        
        return true
    }
    
    // Yeni profil alanlarını sıfırlama
    private func resetNewProfileFields() {
        newProfileName = ""
        newProfileDescription = ""
        newProfileServiceType = .openAI
        newProfileModelId = ""
        newProfileSystemPrompt = ""
        newProfileMemoryEnabled = true
        newProfileWebSearchEnabled = true
        errorMessage = nil
    }
    
    // Seçilen servis türü için mevcut modelleri alma
    func getModelsForSelectedService() -> [AIModel] {
        return newProfileServiceType.service.models
    }
    
    // Profil düzenleme için alanları doldurma
    func fillFieldsForEditing(_ profile: AgentProfile) {
        newProfileName = profile.name
        newProfileDescription = profile.description
        newProfileServiceType = profile.aiServiceType ?? .openAI
        newProfileModelId = profile.modelId
        newProfileSystemPrompt = profile.systemPrompt
        newProfileMemoryEnabled = profile.memoryEnabled
        newProfileWebSearchEnabled = profile.webSearchEnabled
    }
}
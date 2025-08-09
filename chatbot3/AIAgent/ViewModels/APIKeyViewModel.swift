//
//  APIKeyViewModel.swift
//  AIAgent
//
//  Created by Developer on 01.01.2023.
//

import Foundation
import Combine
import SwiftUI

// API anahtarları yönetimi için ViewModel
class APIKeyViewModel: ObservableObject {
    @Published var apiKeys: [APIKeyItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    
    init() {
        loadAPIKeys()
    }
    
    // API anahtarlarını yükleme
    func loadAPIKeys() {
        apiKeys = []
        
        for serviceType in AIServiceType.allCases {
            let service = serviceType.service
            let hasKey = KeychainManager.shared.hasAPIKey(for: service.apiKeyName)
            
            apiKeys.append(APIKeyItem(
                id: UUID(),
                serviceName: service.name,
                apiKeyName: service.apiKeyName,
                hasKey: hasKey
            ))
        }
    }
    
    // API anahtarı ekleme
    func addAPIKey(for serviceName: String, key: String) async {
        guard !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            await setErrorMessage("API anahtarı boş olamaz.")
            return
        }
        
        await setIsLoading(true)
        
        // Servis türünü bul
        guard let serviceType = AIServiceType.allCases.first(where: { $0.service.name == serviceName }) else {
            await setErrorMessage("Geçersiz servis türü.")
            await setIsLoading(false)
            return
        }
        
        do {
            // API anahtarını doğrula
            let isValid = try await AIServiceManager.shared.validateAPIKey(key, for: serviceType)
            
            if isValid {
                // API anahtarını kaydet
                let success = KeychainManager.shared.saveAPIKey(key, for: serviceType.service.apiKeyName)
                
                if success {
                    await setSuccessMessage("API anahtarı başarıyla kaydedildi.")
                    loadAPIKeys()
                } else {
                    await setErrorMessage("API anahtarı kaydedilirken bir hata oluştu.")
                }
            } else {
                await setErrorMessage("Geçersiz API anahtarı.")
            }
            
        } catch {
            await setErrorMessage("API anahtarı doğrulanırken bir hata oluştu: \(error.localizedDescription)")
        }
        
        await setIsLoading(false)
    }
    
    // API anahtarı silme
    func deleteAPIKey(for apiKeyName: String) {
        let success = KeychainManager.shared.deleteAPIKey(for: apiKeyName)
        
        if success {
            successMessage = "API anahtarı başarıyla silindi."
            loadAPIKeys()
        } else {
            errorMessage = "API anahtarı silinirken bir hata oluştu."
        }
    }
    
    // Tüm API anahtarlarını silme
    func deleteAllAPIKeys() {
        KeychainManager.shared.deleteAllAPIKeys()
        successMessage = "Tüm API anahtarları başarıyla silindi."
        loadAPIKeys()
    }
    
    // Yükleme durumunu güncelleme (async)
    @MainActor
    private func setIsLoading(_ loading: Bool) {
        isLoading = loading
    }
    
    // Hata mesajını güncelleme (async)
    @MainActor
    private func setErrorMessage(_ message: String) {
        errorMessage = message
        successMessage = nil
    }
    
    // Başarı mesajını güncelleme (async)
    @MainActor
    private func setSuccessMessage(_ message: String) {
        successMessage = message
        errorMessage = nil
    }
}

// API anahtarı öğesi
struct APIKeyItem: Identifiable {
    let id: UUID
    let serviceName: String
    let apiKeyName: String
    let hasKey: Bool
}
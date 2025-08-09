//
//  KeychainManager.swift
//  AIAgent
//
//  Created by Developer on 01.01.2023.
//

import Foundation
import Security

// Keychain ile API anahtarlarını güvenli bir şekilde yönetmek için sınıf
class KeychainManager {
    static let shared = KeychainManager()
    
    private init() {}
    
    // API anahtarını Keychain'e kaydetme
    func saveAPIKey(_ key: String, for service: String) -> Bool {
        guard let data = key.data(using: .utf8) else { return false }
        
        // Önce mevcut anahtarı sil
        deleteAPIKey(for: service)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "AIAgent",
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    // API anahtarını Keychain'den alma
    func getAPIKey(for service: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "AIAgent",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let key = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return key
    }
    
    // API anahtarını Keychain'den silme
    func deleteAPIKey(for service: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "AIAgent"
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    // Tüm API anahtarlarını silme
    func deleteAllAPIKeys() {
        for serviceType in AIServiceType.allCases {
            deleteAPIKey(for: serviceType.service.apiKeyName)
        }
    }
    
    // Belirli bir servis için API anahtarının var olup olmadığını kontrol etme
    func hasAPIKey(for service: String) -> Bool {
        return getAPIKey(for: service) != nil
    }
}
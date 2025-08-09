//
//  AgentProfileService.swift
//  AIAgent
//
//  Created by Developer on 01.01.2023.
//

import Foundation
import Combine

// Agent profilleri için servis
class AgentProfileService: ObservableObject {
    static let shared = AgentProfileService()
    
    @Published var profiles: [AgentProfile] = []
    
    private let profilesKey = "agent_profiles"
    
    private init() {
        loadProfiles()
    }
    
    // Profilleri yükleme
    private func loadProfiles() {
        if let data = UserDefaults.standard.data(forKey: profilesKey) {
            do {
                let decodedProfiles = try JSONDecoder().decode([AgentProfile].self, from: data)
                self.profiles = decodedProfiles
            } catch {
                print("Profiller yüklenirken hata oluştu: \(error)")
                // Hata durumunda önceden tanımlanmış profilleri kullan
                self.profiles = AgentProfile.presetProfiles
                saveProfiles()
            }
        } else {
            // İlk çalıştırmada önceden tanımlanmış profilleri kullan
            self.profiles = AgentProfile.presetProfiles
            saveProfiles()
        }
    }
    
    // Profilleri kaydetme
    private func saveProfiles() {
        do {
            let data = try JSONEncoder().encode(profiles)
            UserDefaults.standard.set(data, forKey: profilesKey)
        } catch {
            print("Profiller kaydedilirken hata oluştu: \(error)")
        }
    }
    
    // Profil ekleme
    func addProfile(_ profile: AgentProfile) {
        profiles.append(profile)
        saveProfiles()
    }
    
    // Profil güncelleme
    func updateProfile(_ profile: AgentProfile) {
        if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[index] = profile
            saveProfiles()
        }
    }
    
    // Profil silme
    func deleteProfile(id: UUID) {
        profiles.removeAll { $0.id == id }
        saveProfiles()
    }
    
    // ID'ye göre profil bulma
    func getProfile(id: UUID) -> AgentProfile? {
        return profiles.first { $0.id == id }
    }
    
    // Tüm profilleri sıfırlama
    func resetProfiles() {
        profiles = AgentProfile.presetProfiles
        saveProfiles()
    }
}
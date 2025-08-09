//
//  Message.swift
//  AIAgent
//
//  Created by Developer on 01.01.2023.
//

import Foundation

// Mesaj türü
enum MessageType: String, Codable {
    case user = "user"
    case assistant = "assistant"
    case error = "error"
    case webSearch = "webSearch"
}

// Mesaj modeli
struct Message: Identifiable, Codable, Equatable {
    var id: UUID
    var type: MessageType
    var content: String
    var timestamp: Date
    var webSearchResults: [WebSearchResult]?
    
    init(id: UUID = UUID(), type: MessageType, content: String, webSearchResults: [WebSearchResult]? = nil) {
        self.id = id
        self.type = type
        self.content = content
        self.timestamp = Date()
        self.webSearchResults = webSearchResults
    }
    
    // Mesajın tarih formatını almak için
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    // Mesajın tarih ve saat formatını almak için
    var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
}

// Web arama sonucu modeli
struct WebSearchResult: Codable, Identifiable {
    var id: UUID
    var title: String
    var snippet: String
    var url: String
    
    init(id: UUID = UUID(), title: String, snippet: String, url: String) {
        self.id = id
        self.title = title
        self.snippet = snippet
        self.url = url
    }
}

// Memory Yöneticisi
class MemoryManager {
    static let shared = MemoryManager()
    
    private init() {}
    
    // Belirli bir agent profili için tüm görevleri almak
    func getTasks(for agentProfileId: UUID) -> [Task] {
        guard let data = UserDefaults.standard.data(forKey: "tasks_\(agentProfileId.uuidString)") else {
            return []
        }
        
        do {
            let tasks = try JSONDecoder().decode([Task].self, from: data)
            return tasks
        } catch {
            print("Görevler yüklenirken hata oluştu: \(error)")
            return []
        }
    }
    
    // Belirli bir görevi almak
    func getTask(id: UUID) -> Task? {
        // Tüm agent profilleri için görevleri kontrol et
        for serviceType in AIServiceType.allCases {
            for model in serviceType.service.models {
                let tasks = getTasks(for: UUID()) // Burada gerçek agent profil ID'si kullanılmalı
                if let task = tasks.first(where: { $0.id == id }) {
                    return task
                }
            }
        }
        return nil
    }
    
    // Görev kaydetme
    func saveTask(_ task: Task) {
        var tasks = getTasks(for: task.agentProfileId)
        
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        } else {
            tasks.append(task)
        }
        
        do {
            let data = try JSONEncoder().encode(tasks)
            UserDefaults.standard.set(data, forKey: "tasks_\(task.agentProfileId.uuidString)")
        } catch {
            print("Görev kaydedilirken hata oluştu: \(error)")
        }
    }
    
    // Göreve mesaj ekleme
    func addMessage(to taskId: UUID, message: Message) {
        guard var task = getTask(id: taskId) else { return }
        
        task.addMessage(message)
        saveTask(task)
    }
    
    // Belirli bir agent profili için tüm görevleri silme
    func clearTasks(for agentProfileId: UUID) {
        UserDefaults.standard.removeObject(forKey: "tasks_\(agentProfileId.uuidString)")
    }
    
    // Belirli bir görevi silme
    func deleteTask(id: UUID) {
        // Tüm agent profilleri için görevleri kontrol et
        for serviceType in AIServiceType.allCases {
            for model in serviceType.service.models {
                var tasks = getTasks(for: UUID()) // Burada gerçek agent profil ID'si kullanılmalı
                if let index = tasks.firstIndex(where: { $0.id == id }) {
                    tasks.remove(at: index)
                    
                    do {
                        let data = try JSONEncoder().encode(tasks)
                        UserDefaults.standard.set(data, forKey: "tasks_\(UUID().uuidString)") // Burada gerçek agent profil ID'si kullanılmalı
                    } catch {
                        print("Görev silinirken hata oluştu: \(error)")
                    }
                    
                    return
                }
            }
        }
    }
}
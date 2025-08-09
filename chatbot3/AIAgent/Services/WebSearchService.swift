//
//  WebSearchService.swift
//  AIAgent
//
//  Created by Developer on 01.01.2023.
//

import Foundation
import Combine

// Web arama servisi
class WebSearchService {
    static let shared = WebSearchService()
    
    private init() {}
    
    // Web araması için anahtar kelimeler - otomatik tetikleme için kullanılır
    let searchTriggerKeywords = [
        "araştır", "bul", "nedir", "kimdir", "ne zaman", "nerede", "nasıl",
        "güncel", "son", "en son", "haber", "fiyat", "tarih", "olay",
        "research", "find", "what is", "who is", "when", "where", "how to",
        "current", "latest", "news", "price", "date", "event"
    ]
    
    // Mesajda arama tetikleyici kelime olup olmadığını kontrol etme
    func shouldTriggerSearch(for message: String) -> Bool {
        let lowercasedMessage = message.lowercased()
        return searchTriggerKeywords.contains { lowercasedMessage.contains($0.lowercased()) }
    }
    
    // SERP API ile web araması yapma
    func search(query: String) async throws -> [WebSearchResult] {
        // API anahtarını al
        guard let apiKey = KeychainManager.shared.getAPIKey(for: "SERP_API_KEY") else {
            throw WebSearchError.missingAPIKey
        }
        
        // URL oluştur
        let baseURL = "https://serpapi.com/search"
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "engine", value: "google"),
            URLQueryItem(name: "num", value: "5")
        ]
        
        guard let url = components.url else {
            throw WebSearchError.invalidURL
        }
        
        // API isteği gönder
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw WebSearchError.invalidResponse
            }
            
            // Gerçek uygulamada JSON yanıtını parse etme kodu burada olacak
            // Bu örnek için basit bir yanıt oluşturuyoruz
            
            // Örnek arama sonuçları
            let results = [
                WebSearchResult(
                    title: "Arama Sonucu 1",
                    snippet: "Bu bir örnek arama sonucudur. Gerçek uygulamada API'den gelen veriler kullanılacaktır.",
                    url: "https://example.com/1"
                ),
                WebSearchResult(
                    title: "Arama Sonucu 2",
                    snippet: "Bu bir başka örnek arama sonucudur. Gerçek uygulamada API'den gelen veriler kullanılacaktır.",
                    url: "https://example.com/2"
                )
            ]
            
            return results
            
        } catch {
            throw WebSearchError.networkError(error.localizedDescription)
        }
    }
    
    // Arama sonuçlarını özetleme
    func summarizeSearchResults(_ results: [WebSearchResult]) -> String {
        var summary = "Web araması sonuçları:\n\n"
        
        for (index, result) in results.enumerated() {
            summary += "\(index + 1). \(result.title)\n"
            summary += "\(result.snippet)\n"
            summary += "Kaynak: \(result.url)\n\n"
        }
        
        return summary
    }
}

// Web arama hataları
enum WebSearchError: Error {
    case missingAPIKey
    case invalidURL
    case networkError(String)
    case invalidResponse
    case parsingError
    
    var localizedDescription: String {
        switch self {
        case .missingAPIKey:
            return "Web arama API anahtarı bulunamadı. Lütfen ayarlardan bir API anahtarı ekleyin."
        case .invalidURL:
            return "Geçersiz URL oluşturuldu."
        case .networkError(let message):
            return "Ağ hatası: \(message)"
        case .invalidResponse:
            return "Geçersiz yanıt alındı."
        case .parsingError:
            return "Yanıt işlenirken hata oluştu."
        }
    }
}
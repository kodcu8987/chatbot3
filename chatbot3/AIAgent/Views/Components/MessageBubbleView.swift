//
//  MessageBubbleView.swift
//  AIAgent
//
//  Created by Developer on 01.01.2023.
//

import SwiftUI

// Mesaj baloncuğu görünümü
struct MessageBubbleView: View {
    @EnvironmentObject var appSettings: AppSettings
    let message: Message
    
    var body: some View {
        VStack(alignment: message.type == .user ? .trailing : .leading, spacing: 4) {
            HStack {
                if message.type == .user {
                    Spacer(minLength: 60)
                }
                
                VStack(alignment: message.type == .user ? .trailing : .leading, spacing: 4) {
                    // Mesaj içeriği
                    Text(message.content)
                        .padding(12)
                        .background(bubbleBackgroundColor)
                        .foregroundColor(bubbleTextColor)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Web arama sonuçları varsa göster
                    if let webSearchResults = message.webSearchResults, !webSearchResults.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Web Arama Sonuçları")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            ForEach(webSearchResults) { result in
                                WebSearchResultView(result: result)
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                    
                    // Zaman damgası
                    Text(message.formattedTime)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                }
                
                if message.type != .user {
                    Spacer(minLength: 60)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    // Baloncuk arka plan rengi
    private var bubbleBackgroundColor: Color {
        switch message.type {
        case .user:
            return appSettings.currentTheme.primaryColor
        case .assistant:
            return Color(.systemGray5)
        case .error:
            return Color.red.opacity(0.8)
        case .webSearch:
            return Color.blue.opacity(0.8)
        }
    }
    
    // Baloncuk metin rengi
    private var bubbleTextColor: Color {
        switch message.type {
        case .user:
            return .white
        case .assistant, .error, .webSearch:
            return .primary
        }
    }
}

// Web arama sonucu görünümü
struct WebSearchResultView: View {
    let result: WebSearchResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(result.title)
                .font(.caption)
                .fontWeight(.bold)
            
            Text(result.snippet)
                .font(.caption2)
                .lineLimit(3)
            
            Link(result.url, destination: URL(string: result.url) ?? URL(string: "https://example.com")!)
                .font(.caption2)
                .foregroundColor(.blue)
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// Önizleme
struct MessageBubbleView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Kullanıcı mesajı
            MessageBubbleView(message: Message(
                type: .user,
                content: "Merhaba, nasılsın?"
            ))
            
            // Asistan mesajı
            MessageBubbleView(message: Message(
                type: .assistant,
                content: "Merhaba! Ben bir AI asistanıyım. Size nasıl yardımcı olabilirim?"
            ))
            
            // Hata mesajı
            MessageBubbleView(message: Message(
                type: .error,
                content: "API anahtarı bulunamadı. Lütfen ayarlardan bir API anahtarı ekleyin."
            ))
            
            // Web arama sonuçları ile mesaj
            MessageBubbleView(message: Message(
                type: .assistant,
                content: "İşte arama sonuçlarına göre yanıtım.",
                webSearchResults: [
                    WebSearchResult(
                        title: "Örnek Arama Sonucu",
                        snippet: "Bu bir örnek arama sonucudur. Gerçek uygulamada API'den gelen veriler kullanılacaktır.",
                        url: "https://example.com"
                    )
                ]
            ))
        }
        .environmentObject(AppSettings())
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
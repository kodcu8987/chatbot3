//
//  AIAgentApp.swift
//  AIAgent
//
//  Created by Developer on 01.01.2023.
//

import SwiftUI

@main
struct AIAgentApp: App {
    @StateObject private var appSettings = AppSettings()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appSettings)
        }
    }
}

// Uygulama genelinde kullanılacak ayarlar için EnvironmentObject
class AppSettings: ObservableObject {
    @Published var currentTheme: AppTheme = .default
    @Published var selectedAgent: AgentProfile?
    
    // Tema renkleri için enum
    enum AppTheme: String, CaseIterable, Identifiable {
        case `default` = "Varsayılan"
        case dark = "Koyu"
        case light = "Açık"
        case blue = "Mavi"
        case green = "Yeşil"
        
        var id: String { self.rawValue }
        
        var primaryColor: Color {
            switch self {
            case .default: return Color.blue
            case .dark: return Color.gray
            case .light: return Color.orange
            case .blue: return Color.blue
            case .green: return Color.green
            }
        }
        
        var secondaryColor: Color {
            switch self {
            case .default: return Color.purple
            case .dark: return Color.black
            case .light: return Color.yellow
            case .blue: return Color.cyan
            case .green: return Color.mint
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .default: return Color(.systemBackground)
            case .dark: return Color.black
            case .light: return Color.white
            case .blue: return Color(.systemBlue).opacity(0.1)
            case .green: return Color(.systemGreen).opacity(0.1)
            }
        }
    }
}
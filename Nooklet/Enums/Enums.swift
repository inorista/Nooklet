//
//  Enums.swift
//  Nooklet
//
//  Created by Tu on 15/6/26.
//
import Foundation

enum AppTab: String, CaseIterable {
    case home = "Home"
    case chat = "Chat"
    case setting = "Setting"

    var symbolImage: String {
        return switch self {
        case .home: "house.fill"
        case .chat: "magnifyingglass"
        case .setting: "gear"
        }
    }

    func imageName(isActive: Bool) -> String {
        return switch self {
        case .home:
            isActive ? "HomeActive" : "HomeInactive"
        case .chat:
            isActive ? "ExploreActive" : "ExploreInactive"
        case .setting:
            isActive ? "SettingActive" : "SettingInactive"
        }
    }
}

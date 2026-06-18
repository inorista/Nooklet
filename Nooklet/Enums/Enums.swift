//
//  Enums.swift
//  Nooklet
//
//  Created by Tu on 15/6/26.
//
import Foundation

enum AppTab: String, MorphingTabBarProtocol {
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
}

//
//  Enums.swift
//  Nooklet
//
//  Created by Tu on 15/6/26.
//
import Foundation

enum AppTab: String, CaseIterable {
    case home = "Home"
    case explore = "Explore"
    case setting = "Setting"


    func imageName(isActive: Bool) -> String {
        return switch self {
        case .home:
            isActive ? "HomeActive" : "HomeInactive"
        case .explore:
            isActive ? "SpeechActive" : "SpeechInactive"
        case .setting:
            isActive ? "SettingActive" : "SettingInactive"
        }
    }
}

//
//  Enums.swift
//  Nooklet
//
//  Created by Tu on 15/6/26.
//
import Foundation

enum AppTab: String, CaseIterable {
    case home = "Home"
    case speech = "Speech"
    case setting = "Setting"


    func imageName(isActive: Bool) -> String {
        return switch self {
        case .home:
            isActive ? "HomeActive" : "HomeInactive"
        case .speech:
            isActive ? "SpeechActive" : "SpeechInactive"
        case .setting:
            isActive ? "SettingActive" : "SettingInactive"
        }
    }
}

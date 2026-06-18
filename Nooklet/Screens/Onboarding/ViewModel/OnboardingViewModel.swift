//
//  OnboardingViewModel.swift
//  Nooklet
//
//  Created by Tu on 18/6/26.
//

import Foundation

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published private(set) var currentStep: Int = 0
    @Published var onboardingItems: [OnboardingItem] = [
        OnboardingItem(
            title: "Gemma 4 is here!",
            description: "Powered by Gemma 4. Works 100% offline.",
            image: "Gemma"
        ),

        OnboardingItem(
            title: "Speech-to-Text realtime",
            description: "Fast, accurate voice typing via Nemotron 3.5 ASR.",
            image: "Soundwave"
        ),

    ]

}

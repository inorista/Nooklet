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
            description:
                "Powered by Gemma 4. Enjoy fast AI with no internet connection required.",
            image: "Gemma"
        ),

        OnboardingItem(
            title: "Speech-to-Text realtime",
            description:
                "We use the Nemotron 3.5 ASR model to deliver fast and highly accurate speech recognition.",
            image: "Soundwave"
        ),

        OnboardingItem(
            title: "Nooklet",
            description:
                "Get started with Nooklet today!",
            image: "Nooklet"
        ),

    ]

    public func onContinuePressed() {
        if currentStep < onboardingItems.count - 1 {
            currentStep += 1
        } else {
            
        }
    }

    public func onBackPressed() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }

}

//
//  KeyboardUtils.swift
//  Nooklet
//
//  Created by Tu on 22/6/26.
//

import Foundation
import SwiftUI

class KeyboardUtils {
    static func closeKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

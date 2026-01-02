//
//  AppRouter.swift
//  Magneur
//
//  Created by Andrew on 02.01.2026.
//

import SwiftUI

/// Observable router managing the currently active section.
@Observable
final class AppRouter {
    /// The currently displayed section.
    var currentSection: AppSection = .fitness
}

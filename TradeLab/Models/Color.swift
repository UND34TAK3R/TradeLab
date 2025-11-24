//
//  Color.swift
//  TradeLab
//
//  Created by Justin Pescador on 2025-11-24.
//

import SwiftUI

extension Color {
    // Gradient colors
    static var themeGradientStart: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 1.0)
            : UIColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0)
        })
    }
    
    static var themeGradientEnd: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.5, green: 0.3, blue: 0.7, alpha: 1.0)
                : UIColor(red: 0.6, green: 0.4, blue: 0.8, alpha: 1.0)
        })
    }
    
    // Text colors
    static var themePrimary: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.white
                : UIColor.white
        })
    }
    
    static var themeSecondary: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(white: 0.8, alpha: 1.0)
                : UIColor(white: 1.0, alpha: 0.7)
        })
    }
    
    // Overlay colors (textfields + cards)
    static var themeOverlay: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(white: 1.0, alpha: 0.25)
                : UIColor(white: 1.0, alpha: 0.2)
        })
    }
    
    static var themeOverlaySecondary: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(white: 1.0, alpha: 0.2)
                : UIColor(white: 1.0, alpha: 0.15)
        })
    }
    
    static var themeBorder: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(white: 1.0, alpha: 0.5)
                : UIColor(white: 1.0, alpha: 0.4)
        })
    }
    
    static var themeBorderSecondary: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(white: 1.0, alpha: 0.4)
                : UIColor(white: 1.0, alpha: 0.3)
        })
    }
}

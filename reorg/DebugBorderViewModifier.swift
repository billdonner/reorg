//
//  DebugBorderViewModifier.swift
//  qandao
//
//  Created by bill donner on 8/18/24.
//

import SwiftUI



// MARK: - DebugBorder ViewModifier
// ViewModifier to apply a one-pixel border around a view
struct DebugBorder: ViewModifier {
    // Optional color parameter, defaults to global debugBorderColor
    var color: Color?
    // Boolean to force the border regardless of global setting
    var forceShow: Bool = false

    func body(content: Content) -> some View {
        content
            .overlay(
                // Show the border if global debug mode is enabled or if forced
                (isDebugModeEnabled || forceShow) ?
                    AnyView(Rectangle().stroke(color ?? debugBorderColor, lineWidth: 1)) :
                    AnyView(EmptyView())
            )
    }
}

// MARK: - View Extension
// Extension to make the modifier easy to apply
extension View {
    func debugBorder(_ color: Color? = nil, forceShow: Bool = false) -> some View {
        self.modifier(DebugBorder(color: color, forceShow: forceShow))
    }
}

// MARK: - Test View
// A test view demonstrating all the features of the DebugBorder modifier
struct DebugBorderTestView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Default usage, follows global `isDebugModeEnabled`
            Text("Default Border")
                .debugBorder()
            
            // Custom color, follows global `isDebugModeEnabled`
            Text("Custom Blue Border")
                .debugBorder(.blue)
            
            // Forced border, regardless of global `isDebugModeEnabled`
            Text("Forced Red Border")
                .debugBorder(forceShow: true)
            
            // Forced border with custom color
            Text("Forced Green Border")
                .debugBorder(.green, forceShow: true)
        }
        .padding()
    }
}

// MARK: - Preview
// Preview provider to test the view in Xcode's canvas
struct DebugBorderTestView_Previews: PreviewProvider {
    static var previews: some View {
        // You can toggle the global debug mode here to see the effect
       // isDebugModeEnabled = true // Set to true or false for testing
       //klkmlmlk debugBorderColor = .red

        return DebugBorderTestView()
    }
}

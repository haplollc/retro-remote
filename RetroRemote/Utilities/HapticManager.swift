import UIKit

/// Manages haptic feedback for button interactions
class HapticManager {
    static let shared = HapticManager()
    
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let notificationFeedback = UINotificationFeedbackGenerator()
    
    private init() {
        // Prepare generators for faster response
        prepareAll()
    }
    
    func prepareAll() {
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        selectionFeedback.prepare()
        notificationFeedback.prepare()
    }
    
    /// Light tap for most buttons
    func lightTap() {
        lightImpact.impactOccurred()
        lightImpact.prepare()
    }
    
    /// Medium tap for important buttons like select
    func mediumTap() {
        mediumImpact.impactOccurred()
        mediumImpact.prepare()
    }
    
    /// Heavy tap for power button
    func heavyTap() {
        heavyImpact.impactOccurred()
        heavyImpact.prepare()
    }
    
    /// Selection changed feedback
    func selectionChanged() {
        selectionFeedback.selectionChanged()
        selectionFeedback.prepare()
    }
    
    /// Success notification
    func success() {
        notificationFeedback.notificationOccurred(.success)
        notificationFeedback.prepare()
    }
    
    /// Warning notification
    func warning() {
        notificationFeedback.notificationOccurred(.warning)
        notificationFeedback.prepare()
    }
    
    /// Error notification
    func error() {
        notificationFeedback.notificationOccurred(.error)
        notificationFeedback.prepare()
    }
    
    /// Get appropriate haptic for a remote button
    func hapticForButton(_ button: RemoteButton) {
        switch button {
        case .power:
            heavyTap()
        case .select, .home, .menu:
            mediumTap()
        case .volumeUp, .volumeDown, .channelUp, .channelDown:
            selectionChanged()
        default:
            lightTap()
        }
    }
}

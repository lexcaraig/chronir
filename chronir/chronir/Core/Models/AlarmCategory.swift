import SwiftUI

enum AlarmCategory: String, Codable, CaseIterable, Identifiable {
    case home
    case health
    case finance
    case vehicle
    case work
    case personal
    case pets
    case subscriptions

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .home: return "Home"
        case .health: return "Health"
        case .finance: return "Finance"
        case .vehicle: return "Vehicle"
        case .work: return "Work"
        case .personal: return "Personal"
        case .pets: return "Pets"
        case .subscriptions: return "Subscriptions"
        }
    }

    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .health: return "heart.fill"
        case .finance: return "dollarsign.circle.fill"
        case .vehicle: return "car.fill"
        case .work: return "briefcase.fill"
        case .personal: return "person.fill"
        case .pets: return "pawprint.fill"
        case .subscriptions: return "creditcard.fill"
        }
    }

    var color: Color {
        switch self {
        case .home: return ColorTokens.categoryHome
        case .health: return ColorTokens.categoryHealth
        case .finance: return ColorTokens.categoryFinance
        case .vehicle: return ColorTokens.categoryVehicle
        case .work: return ColorTokens.categoryWork
        case .personal: return ColorTokens.categoryPersonal
        case .pets: return ColorTokens.categoryPets
        case .subscriptions: return ColorTokens.categorySubscriptions
        }
    }
}

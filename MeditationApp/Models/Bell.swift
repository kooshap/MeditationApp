import Foundation

enum Bell: String, CaseIterable, Codable {
    case tibetan
    case zenBowl  = "zen_bowl"
    case crystal
    case chime
    case gong

    var displayName: String {
        switch self {
        case .tibetan: return "Tibetan"
        case .zenBowl: return "Zen Bowl"
        case .crystal: return "Crystal"
        case .chime:   return "Chime"
        case .gong:    return "Gong"
        }
    }

    // SF Symbol used as placeholder icon in the bell carousel
    var icon: String {
        switch self {
        case .tibetan: return "circle.circle.fill"
        case .zenBowl: return "oval.portrait.fill"
        case .crystal: return "diamond.fill"
        case .chime:   return "triangle.fill"
        case .gong:    return "octagon.fill"
        }
    }

    // Audio file must be placed in Resources/ with this name + .mp3 extension
    var filename: String { rawValue }
}

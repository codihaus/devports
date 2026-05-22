import SwiftUI

enum DevFramework: String, CaseIterable, Sendable {
    case vite, nextjs, nuxt, webpack, remix, astro
    case node, bun, deno
    case python, ruby, php, go, java
    case ollama
    case unknown

    var displayName: String {
        switch self {
        case .vite: "Vite"
        case .nextjs: "Next.js"
        case .nuxt: "Nuxt"
        case .webpack: "Webpack"
        case .remix: "Remix"
        case .astro: "Astro"
        case .node: "Node.js"
        case .bun: "Bun"
        case .deno: "Deno"
        case .python: "Python"
        case .ruby: "Ruby"
        case .php: "PHP"
        case .go: "Go"
        case .java: "Java"
        case .ollama: "Ollama"
        case .unknown: "Unknown"
        }
    }

    var iconName: String {
        switch self {
        case .vite: "bolt.fill"
        case .nextjs: "n.square.fill"
        case .nuxt: "leaf.fill"
        case .webpack: "cube.fill"
        case .remix: "arrow.triangle.2.circlepath"
        case .astro: "sparkles"
        case .node: "circle.hexagongrid.fill"
        case .bun: "circle.fill"
        case .deno: "diamond.fill"
        case .python: "chevron.left.forwardslash.chevron.right"
        case .ruby: "diamond.fill"
        case .php: "chevron.left.forwardslash.chevron.right"
        case .go: "hare.fill"
        case .java: "cup.and.saucer.fill"
        case .ollama: "brain.head.profile"
        case .unknown: "questionmark.circle"
        }
    }

    var color: Color {
        switch self {
        case .vite: .purple
        case .nextjs: .primary
        case .nuxt: .green
        case .webpack: .blue
        case .remix: .pink
        case .astro: .orange
        case .node: .green
        case .bun: .yellow
        case .deno: .cyan
        case .python: .yellow
        case .ruby: .red
        case .php: .indigo
        case .go: .cyan
        case .java: .red
        case .ollama: .white
        case .unknown: .gray
        }
    }

    static func detect(from args: String, processName: String) -> DevFramework {
        let lower = args.lowercased()
        let name = processName.lowercased()

        if name == "ollama" { return .ollama }
        if name == "bun" { return lower.contains("vite") ? .vite : .bun }
        if name == "deno" { return .deno }
        if name == "python" || name == "python3" { return .python }
        if name == "ruby" { return .ruby }
        if name == "php" { return .php }
        if name == "go" { return .go }
        if name == "java" { return .java }

        if lower.contains("next") && (lower.contains("dev") || lower.contains("start")) { return .nextjs }
        if lower.contains("nuxt") { return .nuxt }
        if lower.contains("remix") { return .remix }
        if lower.contains("astro") { return .astro }
        if lower.contains("webpack-dev-server") || lower.contains("webpack serve") { return .webpack }
        if lower.contains("vite") { return .vite }

        if name == "node" { return .node }
        return .unknown
    }
}

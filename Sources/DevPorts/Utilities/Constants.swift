import Foundation

enum Constants {
    static let processNameFilter: Set<String> = [
        "node", "bun", "deno",
        "python", "python3",
        "ruby", "php", "go", "java",
        "ollama"
    ]

    static let defaultRefreshInterval: Double = 5.0
    static let refreshIntervals: [Double] = [2, 5, 10, 30]
}

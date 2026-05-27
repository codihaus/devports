import Foundation

enum ProjectDetector {
    nonisolated(unsafe) private static var cache: [Int32: (name: String, timestamp: Date)] = [:]
    private static let cacheTTL: TimeInterval = 30

    static func projectName(for pid: Int32, at cwd: String) -> String {
        if let cached = cache[pid], Date().timeIntervalSince(cached.timestamp) < cacheTTL {
            return cached.name
        }

        let name = detectName(at: cwd)
        cache[pid] = (name, Date())
        return name
    }

    static func invalidate(pid: Int32) {
        cache.removeValue(forKey: pid)
    }

    private static func detectName(at cwd: String) -> String {
        if let name = readPackageJson(at: cwd) { return name }
        if let name = readPyprojectToml(at: cwd) { return name }
        if let name = readGoMod(at: cwd) { return name }
        if let name = readComposerJson(at: cwd) { return name }
        return folderName(at: cwd)
    }

    private static func readPackageJson(at cwd: String) -> String? {
        let path = (cwd as NSString).appendingPathComponent("package.json")
        guard let data = FileManager.default.contents(atPath: path),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let name = json["name"] as? String,
              !name.isEmpty else { return nil }
        if name.contains("/") {
            return String(name.split(separator: "/").last ?? "")
        }
        return name
    }

    private static func readPyprojectToml(at cwd: String) -> String? {
        let path = (cwd as NSString).appendingPathComponent("pyproject.toml")
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else { return nil }
        for line in content.split(separator: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("name") && trimmed.contains("=") {
                let value = trimmed.split(separator: "=", maxSplits: 1).last?
                    .trimmingCharacters(in: .whitespaces)
                    .trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
                if let value, !value.isEmpty { return value }
            }
        }
        return nil
    }

    private static func readGoMod(at cwd: String) -> String? {
        let path = (cwd as NSString).appendingPathComponent("go.mod")
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else { return nil }
        for line in content.split(separator: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("module ") {
                let modulePath = trimmed.dropFirst("module ".count)
                    .trimmingCharacters(in: .whitespaces)
                return String(modulePath.split(separator: "/").last ?? "")
            }
        }
        return nil
    }

    private static func readComposerJson(at cwd: String) -> String? {
        let path = (cwd as NSString).appendingPathComponent("composer.json")
        guard let data = FileManager.default.contents(atPath: path),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let name = json["name"] as? String,
              !name.isEmpty else { return nil }
        if name.contains("/") {
            return String(name.split(separator: "/").last ?? "")
        }
        return name
    }

    private static func folderName(at cwd: String) -> String {
        let url = URL(fileURLWithPath: cwd)
        let name = url.lastPathComponent
        return name == "/" ? "root" : name
    }
}

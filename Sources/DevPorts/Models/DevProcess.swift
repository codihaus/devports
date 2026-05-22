import Foundation

struct DevProcess: Identifiable, Equatable {
    var id: Int32 { pid }
    let pid: Int32
    let name: String
    let framework: DevFramework
    let commandArgs: String
    let ports: [UInt16]
    let workingDirectory: String
    let executablePath: String
    let projectName: String

    var displayPath: String {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        if workingDirectory.hasPrefix(home) {
            return "~" + workingDirectory.dropFirst(home.count)
        }
        return workingDirectory
    }

    var portDisplay: String {
        ports.map(String.init).joined(separator: ", ")
    }
}

import Foundation
import Darwin

enum ProcessScanner {
    struct RawRecord {
        var pid: Int32 = 0
        var command: String = ""
        var ports: Set<UInt16> = []
    }

    static func scan() -> [DevProcess] {
        let records = parseLsof()
        return records.compactMap { buildDevProcess(from: $0) }
    }

    private static func parseLsof() -> [RawRecord] {
        guard let output = ShellCommand.run("lsof -iTCP -sTCP:LISTEN -P -n -F pcn") else {
            return []
        }

        var recordsByPid: [Int32: RawRecord] = [:]
        var currentPid: Int32 = 0

        for line in output.split(separator: "\n") {
            guard let firstChar = line.first else { continue }
            let value = String(line.dropFirst())

            switch firstChar {
            case "p":
                if let pid = Int32(value) {
                    currentPid = pid
                    if recordsByPid[pid] == nil {
                        recordsByPid[pid] = RawRecord(pid: pid)
                    }
                }
            case "c":
                recordsByPid[currentPid]?.command = value
            case "n":
                if let port = extractPort(from: value) {
                    recordsByPid[currentPid]?.ports.insert(port)
                }
            default:
                break
            }
        }

        return recordsByPid.values.filter { record in
            Constants.processNameFilter.contains(record.command.lowercased())
        }
    }

    private static func extractPort(from networkName: String) -> UInt16? {
        guard let lastColon = networkName.lastIndex(of: ":") else { return nil }
        let portString = String(networkName[networkName.index(after: lastColon)...])
        return UInt16(portString)
    }

    private static func buildDevProcess(from record: RawRecord) -> DevProcess? {
        let args = ShellCommand.run("ps -p \(record.pid) -o args=") ?? record.command
        let cwd = getWorkingDirectory(pid: record.pid) ?? "/"
        let exePath = getExecutablePath(pid: record.pid) ?? ""

        let framework = DevFramework.detect(from: args, processName: record.command)
        let projectName = ProjectDetector.projectName(for: record.pid, at: cwd)

        return DevProcess(
            pid: record.pid,
            name: record.command,
            framework: framework,
            commandArgs: args,
            ports: record.ports.sorted(),
            workingDirectory: cwd,
            executablePath: exePath,
            projectName: projectName
        )
    }

    private static func getWorkingDirectory(pid: Int32) -> String? {
        var vnodeInfo = proc_vnodepathinfo()
        let size = MemoryLayout<proc_vnodepathinfo>.size
        let result = proc_pidinfo(pid, PROC_PIDVNODEPATHINFO, 0, &vnodeInfo, Int32(size))

        guard result == size else { return nil }

        let path = withUnsafePointer(to: vnodeInfo.pvi_cdir.vip_path) { ptr in
            ptr.withMemoryRebound(to: CChar.self, capacity: Int(MAXPATHLEN)) { cpath in
                String(cString: cpath)
            }
        }

        return path.isEmpty ? nil : path
    }

    private static func getExecutablePath(pid: Int32) -> String? {
        var buffer = [CChar](repeating: 0, count: 4096)
        let result = proc_pidpath(pid, &buffer, UInt32(buffer.count))
        guard result > 0 else { return nil }
        return String(cString: buffer)
    }
}

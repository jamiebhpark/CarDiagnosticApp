import Foundation

class WarningManager {
    private let maxWarningLogs = 50
    private var warningLogs: [WarningLog] = []

    func logWarning(type: String, message: String) {
        let log = WarningLog(date: Date(), type: type, message: message)
        warningLogs.append(log)
        if warningLogs.count > maxWarningLogs {
            warningLogs.removeFirst()
        }
        
        saveWarningLogs() // 변경된 로그 저장
    }

    func getWarningLogs() -> [WarningLog] {
        return warningLogs
    }

    private func saveWarningLogs() {
        if let data = try? JSONEncoder().encode(warningLogs) {
            UserDefaults.standard.set(data, forKey: "WarningLogs")
        }
    }

    func loadWarningLogs() {
        if let data = UserDefaults.standard.data(forKey: "WarningLogs"),
           let logs = try? JSONDecoder().decode([WarningLog].self, from: data) {
            warningLogs = logs
        }
    }
}

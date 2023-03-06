#!/usr/bin/swift

import Foundation

private let fileManager = FileManager.default
private let projectPath = fileManager.currentDirectoryPath + "/rootFolderNameHere"
private var filesURL: [URL] = []
private var allLocalizedStrings: [String: Int] = [:]
private var shouldShowUnusedStrings: Bool {
    guard CommandLine.argc > 1 else { return false }
    return CommandLine.arguments.contains("-u") || CommandLine.arguments.contains("--unused")
}

private var helpInformation: String {
    """
    
        OPTIONAL ARGUMENTS:
            -h, --help          Print this help text
            -d, --delete        Delete unused localized strings
            -u, --unused        Print all unused localized strings
    
        USAGE EXAMPLES:
        ./localizedRemover.swift --delete
        ./localizedRemover.swift --help
    
    """
}

// MARK: - Start script
showHelpInfoIfNeeded()
print("------------------------------------\nRemoving unused localized strings 🧨\n------------------------------------\n")
allLocalizedStrings = getLocalizableStrings()
print("-> Scanning files...🔍\n")
findAllSwiftFilePaths()
print("-> Searching for unused strings...🧐\n")
findUnsedLocalizedStrings()
showUnusedStrings()
removeUnusedStrings()


// MARK: - Private methods
private func showHelpInfoIfNeeded() {
    guard CommandLine.argc > 1 else { return }
    guard CommandLine.arguments.contains("-h") || CommandLine.arguments.contains("--help") else { return }
    print(helpInformation)
    exit(0)
}

private func getLocalizableStrings() -> [String: Int] {
    let localizedStringsPath = projectPath + "/Base.lproj/Localizable.strings"
    
    let localizedStringsUrl = URL(fileURLWithPath: localizedStringsPath)
    do {
        var localizedStrings: [String: Int] = [:]
        let data = try String(contentsOf: localizedStringsUrl, encoding: .utf8)
        let array = data.components(separatedBy: .newlines)

        for string in array {
            guard string.contains("=") else { continue }
            let line = string.split(separator: "=")
            guard line.count > 0 else { continue }
            let key = line[0]
            localizedStrings["\(key)"] = 0
        }
        return localizedStrings
    } catch {
        print("Error")
        return [:]
    }
}

private func findAllSwiftFilePaths() {
    let projectURL = URL(fileURLWithPath: projectPath)
    
    do {
        let allSwiftFilesURLS = try deepSearch(projectURL)
        
        if allSwiftFilesURLS.isEmpty {
            print("-> No Swift files found in the path provided. ⛔️\n")
        }
        
        filesURL = allSwiftFilesURLS
    } catch {
        print("-> Error finding Swift files\n")
    }
}

private func findUnsedLocalizedStrings() {
    filesURL.forEach { fileURL in
        checkFile(with: fileURL)
    }
}

private func checkFile(with path: URL) {
    do {
        var fileText = try String(contentsOf: path, encoding: .utf8)
        fileText = fileText.replacingOccurrences(of: ",", with: " ")
        fileText = fileText.replacingOccurrences(of: "(", with: " ")
        fileText = fileText.replacingOccurrences(of: ")", with: " ")
        fileText = fileText.replacingOccurrences(of: ".localized", with: " ")
        
        for (key, value) in allLocalizedStrings {
            if fileText.range(of: key) != nil {
                allLocalizedStrings[key] = value + 1
            }
        }
    } catch {
        print("Error")
    }
}

private func showUnusedStrings() {
    var unusedCount = 0
    
    var unusedStrigsList: String = ""
    for (key,value) in allLocalizedStrings {
        if value == 0 {
            unusedCount += 1
            unusedStrigsList += "\(key)\n"
        }
    }
    
    if shouldShowUnusedStrings {
        print("-> Unused localized strings found:\n")
        print(unusedStrigsList)
    }
    
    print("-> Total unused localized strings found: \(unusedCount)\n")
}

private func removeUnusedStrings() {
    guard CommandLine.argc > 1 else { return }
    if CommandLine.arguments.contains("-d") || CommandLine.arguments.contains("--delete") {
        // TODO: Remove unused strings
        print("-> Successfully removed unused localized strings. Localizable.strings file updated ✅\n")
    }
}


// MARK: - Find all swift files

private func deepSearch(_ directory: URL) throws -> [URL] {
    guard let enumerator = FileManager.default.enumerator(at: directory,
                                                          includingPropertiesForKeys: [.isRegularFileKey],
                                                          options: [FileManager.DirectoryEnumerationOptions.skipsHiddenFiles]) else { return [] }
    
    return enumerator
        .compactMap { $0 as? URL }
        .filter { $0.pathExtension == "swift" }
}


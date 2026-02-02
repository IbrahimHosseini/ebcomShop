//
//  OSLogger.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//


import Foundation
import os.log

/// A lightweight wrapper around the unified logging system that standardizes log output across the app.
///
/// OSLogger provides:
/// - A single entry point to log one or more values with a chosen OSLogType (default, error, fault, etc.)
/// - Consistent, human-readable prefixes including:
///   - An emoji sign derived from the log type (ℹ️, ⚠️, 🔴)
///   - A category label to group related logs
///   - A timestamp using a concise date/time format
///   - Source context (file name, function, and line number)
/// - Configurable item delimiters to control how multiple logged values are separated
///
/// Usage:
/// - Call `OSLogger.log(...)` from anywhere to emit a structured log entry.
/// - Choose a `Category` to group logs for a specific app component.
/// - Optionally specify a `Delimiter` to separate multiple logged values.
///
/// Implementation details:
/// - Internally constructs an `OSLog` using the app’s bundle identifier as the subsystem and the provided category.
/// - Uses `os_log` to write messages to the unified logging system.
/// - Automatically infers caller information (function, file, line) via default parameter values.
///
/// Notes:
/// - Categories are defined by the nested `Category` enum and can be extended to fit the app’s modules.
/// - Delimiters are defined by the nested `Delimiter` enum (space, tab, slashes, etc.).
/// - The formatted prefix includes a pipe (`|`) separator before the message body.
/// - The `OSLogType` extension maps log types to emoji signs for quick visual scanning in logs.
///
/// Considerations:
/// - Avoid logging sensitive information with `%{public}@` unless intended to be visible in public logs.
/// - Ensure the app's bundle identifier is available; the current implementation
///   force-unwraps it when creating `OSLog`.
enum OSLogger {
    /// Logs one or more values to the unified logging system with a standardized, human‑readable format.
    ///
    /// This convenience method builds a structured log message that includes:
    /// - An emoji indicator derived from the `OSLogType` (ℹ️ for default/info, ⚠️ for error, 🔴 for fault)
    /// - A category label (`Category`) to group related logs
    /// - A concise timestamp
    /// - Source context (file name, function name, and line number)
    /// - A pipe (`|`) separator before the message body
    /// - The provided items, joined using the selected `Delimiter`
    ///
    /// The message is written using `os_log` with `%{public}@`, making the content visible in public logs.
    /// Avoid passing sensitive information unless you intend it to be publicly readable.
    ///
    /// - Parameters:
    ///   - items: One or more values to include in the log entry. Each item is converted using `String(describing:)`.
    ///   - type: The `OSLogType` for the entry (e.g., `.default`, `.error`, `.fault`). Defaults to `.default`.
    ///   - category: The logical category for the log, used to construct the `OSLog` instance. Defaults to `.default`.
    ///   - delimiter: The separator inserted between `items` in the message body. Defaults to `.space`.
    ///   - function: The calling function name. Defaults to `#function`; do not override in typical use.
    ///   - file: The calling file path. Defaults to `#file`; do not override in typical use.
    ///     Only the last path component is shown.
    ///   - line: The source line number. Defaults to `#line`; do not override in typical use.
    ///
    /// - Important: The underlying `OSLog` is created with the app’s bundle identifier as the subsystem and a category
    ///   prefixed with `"ContentBlocker "`. Ensure the bundle identifier is available at runtime.
    ///
    /// - SeeAlso: `OSLogger.Category`, `OSLogger.Delimiter`, `OSLogType`
    static func log(
        _ items: Any...,
        type: OSLogType = .default,
        category: Category = .default,
        delimiter: Delimiter = .space,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        #if DEBUG
            let file = lastPath(file)

            let prefix = "\(type.sign) [\(category.rawValue)] [\(formattedDate)] " +
                "[\(file), \(function), line: \(line)] |"
            var message = prefix

            for item in items {
                message.append(delimiter.rawValue)
                message.append(String(describing: item))
            }

            let log = getLog(category)

            write(message, log: log, type: type)
        #endif
    }

    // MARK: - Convenience Methods

    /// Logs with default type (info) - only logs in DEBUG mode
    static func info(
        _ items: Any...,
        category: Category = .default,
        delimiter: Delimiter = .space,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        log(items, type: .default, category: category, delimiter: delimiter, function: function, file: file, line: line)
    }

    /// Logs with error type (warning) - only logs in DEBUG mode
    static func warning(
        _ items: Any...,
        category: Category = .default,
        delimiter: Delimiter = .space,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        log(
            items,
            type: .error,
            category: category,
            delimiter: delimiter,
            function: function,
            file: file,
            line: line
        )
    }

    /// Logs with fault type (failure) - only logs in DEBUG mode
    static func error(
        _ items: Any...,
        category: Category = .default,
        delimiter: Delimiter = .space,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        log(
            items,
            type: .fault,
            category: category,
            delimiter: delimiter,
            function: function,
            file: file,
            line: line
        )
    }

    /// Defines the available logging categories for different app components.
    enum Category: String {
        case `default` = "EBCOM SHOP"
    }

    /// Defines the possible delimiters used between logged items in the output.
    enum Delimiter: String {
        case space = " "
        case stare = "*"
        case slash = "/"
        case backslash = "\\"
        case tab = "    "
        case dualStare = "**"
        case dualEqual = "=="
        case separator = "|"
    }
}

private extension OSLogger {
    /// Extracts the last path component from a file path string.
    static func lastPath(_ file: String) -> String {
        URL(string: file)?.lastPathComponent ?? ""
    }

    /// Returns the current date and time formatted for log output.
    static var formattedDate: String {
        Date().formatted(date: .abbreviated, time: .standard)
    }

    /// Returns an `OSLog` instance configured for the given category.
    static func getLog(_ category: Category) -> OSLog {
        OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "ContentBlocker " + category.rawValue)
    }

    /// Writes the given text to the unified logging system using the specified log and type.
    static func write(
        _ text: String,
        log: OSLog,
        type: OSLogType
    ) {
        os_log("%{public}@", log: log, type: type, text)
    }
}

extension OSLogType {
    /// Returns an emoji indicator corresponding to the log type (`fault`, `error`, or default).
    var sign: String {
        switch self {
        case .fault: "🔴"
        case .error: "⚠️"
        default: "ℹ️"
        }
    }
}

/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-2020 Datadog, Inc.
 */

import Foundation

/// Prepares and owns logs persistency stack.
internal struct LogsPersistenceStrategy {
    struct Constants {
        /// Subdirectory in `/Library/Caches` where log files are stored.
        static let logFilesSubdirectory: String = "com.datadoghq.logs/v1"
    }

    // MARK: - Initialization

    init(environment: Environment, dateProvider: DateProvider) throws {
        let directory = try Directory(withSubdirectoryPath: Constants.logFilesSubdirectory)
        let readWriteQueue = DispatchQueue(
            label: "com.datadoghq.ios-sdk-logs-read-write",
            target: .global(qos: .utility)
        )
        let orchestrator = FilesOrchestrator(
            directory: directory,
            writeConditions: WritableFileConditions(environment: environment),
            readConditions: ReadableFileConditions(environment: environment),
            dateProvider: dateProvider
        )

        self.init(
            writer: FileWriter(
                orchestrator: orchestrator,
                queue: readWriteQueue,
                maxWriteSize: environment.maxLogSize
            ),
            reader: FileReader(
                orchestrator: orchestrator,
                queue: readWriteQueue
            )
        )
    }

    init(writer: FileWriter, reader: FileReader) {
        self.writer = writer
        self.reader = reader
    }

    // MARK: - Strategy

    /// Writes logs to files.
    let writer: FileWriter

    /// Reads logs from files.
    let reader: FileReader
}

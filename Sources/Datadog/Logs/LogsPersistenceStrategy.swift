/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-2020 Datadog, Inc.
 */

import Foundation

/// Prepares and owns logs persistency stack.
internal struct LogsPersistenceStrategy {
    // MARK: - Initialization

    init(environment: Environment, dateProvider: DateProvider) throws {
        let directory = try Directory(withSubdirectoryPath: environment.logFilesSubdirectory)
        let readWriteQueue = DispatchQueue(
            label: "com.datadoghq.ios-sdk-logs-read-write",
            target: .global(qos: .utility)
        )
        self.init(
            environment: environment,
            directory: directory,
            dateProvider: dateProvider,
            readWriteQueue: readWriteQueue,
            writeConditions: WritableFileConditions(environment: environment),
            readConditions: ReadableFileConditions(environment: environment)
        )
    }

    init(
        environment: Environment,
        directory: Directory,
        dateProvider: DateProvider,
        readWriteQueue: DispatchQueue,
        writeConditions: WritableFileConditions,
        readConditions: ReadableFileConditions
    ) {
        let orchestrator = FilesOrchestrator(
            directory: directory,
            writeConditions: writeConditions,
            readConditions: readConditions,
            dateProvider: dateProvider
        )

        self.writer = FileWriter(
            orchestrator: orchestrator,
            queue: readWriteQueue,
            maxWriteSize: environment.maxLogSize
        )
        self.reader = FileReader(
            orchestrator: orchestrator,
            queue: readWriteQueue
        )
    }

    // MARK: - Strategy

    /// Writes logs to files.
    let writer: FileWriter

    /// Reads logs from files.
    let reader: FileReader
}

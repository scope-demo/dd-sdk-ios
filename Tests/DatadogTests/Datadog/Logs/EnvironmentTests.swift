/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-2020 Datadog, Inc.
 */

import XCTest
@testable import Datadog

class EnvironmentTests: XCTestCase {
    func testEnvironmentConsistency() {
        let environments: [Environment] = [.app, .appExtension]

        environments.map { $0.configuration }.forEach { configuration in
            XCTAssertLessThan(
                configuration.maxBatchSize,
                configuration.maxSizeOfLogsDirectory,
                "Size of individual file must not exceed the directory size limit."
            )
            XCTAssertLessThan(
                configuration.maxFileAgeForWrite,
                configuration.minFileAgeForRead,
                "File should not be considered for upload (read) while it is eligible for writes."
            )
            XCTAssertGreaterThan(
                configuration.maxFileAgeForRead,
                configuration.minFileAgeForRead,
                "File read boundaries must be consistent."
            )
            XCTAssertGreaterThan(
                configuration.maxLogsUploadDelay,
                configuration.minLogsUploadDelay,
                "Upload delay boundaries must be consistent."
            )
            XCTAssertGreaterThan(
                configuration.maxLogsUploadDelay,
                configuration.minLogsUploadDelay,
                "Upload delay boundaries must be consistent."
            )
            XCTAssertLessThanOrEqual(
                configuration.logsUploadDelayDecreaseFactor,
                1,
                "Upload delay should not be increased towards infinity."
            )
            XCTAssertGreaterThan(
                configuration.logsUploadDelayDecreaseFactor,
                0,
                "Upload delay must never result with 0."
            )
        }
    }
}

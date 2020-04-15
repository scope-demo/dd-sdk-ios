/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-2020 Datadog, Inc.
 */

import Foundation

/// Mutable interval used for periodic data uploads.
internal struct DataUploadDelay {
    private let defaultDelay: TimeInterval
    private let minDelay: TimeInterval
    private let maxDelay: TimeInterval
    private let decreaseFactor: Double

    private var delay: TimeInterval

    init(environment: Environment.Configuration) {
        self.defaultDelay = environment.defaultLogsUploadDelay
        self.minDelay = environment.minLogsUploadDelay
        self.maxDelay = environment.maxLogsUploadDelay
        self.decreaseFactor = environment.logsUploadDelayDecreaseFactor
        self.delay = environment.initialLogsUploadDelay
    }

    mutating func nextUploadDelay() -> TimeInterval {
        defer {
            if delay == maxDelay {
                delay = defaultDelay
            }
        }
        return delay
    }

    mutating func decrease() {
        delay = max(minDelay, delay * decreaseFactor)
    }

    mutating func increaseOnce() {
        delay = maxDelay
    }
}

/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-2020 Datadog, Inc.
 */

import XCTest
@testable import Datadog

class DataUploadDelayTests: XCTestCase {
    private let mockEnvironment: Environment.Configuration = .mockWith(
        initialLogsUploadDelay: 3,
        defaultLogsUploadDelay: 5,
        minLogsUploadDelay: 1,
        maxLogsUploadDelay: 20,
        logsUploadDelayDecreaseFactor: 0.9
    )

    func testWhenNotModified_itReturnsInitialDelay() {
        var delay = DataUploadDelay(environment: mockEnvironment)
        XCTAssertEqual(delay.nextUploadDelay(), mockEnvironment.initialLogsUploadDelay)
        XCTAssertEqual(delay.nextUploadDelay(), mockEnvironment.initialLogsUploadDelay)
    }

    func testWhenDecreasing_itGoesDownToMinimumDelay() {
        var delay = DataUploadDelay(environment: mockEnvironment)
        var previousValue: TimeInterval = delay.nextUploadDelay()

        while previousValue != mockEnvironment.minLogsUploadDelay {
            delay.decrease()

            let nextValue = delay.nextUploadDelay()
            XCTAssertEqual(
                nextValue / previousValue,
                mockEnvironment.logsUploadDelayDecreaseFactor,
                accuracy: 0.1
            )
            XCTAssertLessThanOrEqual(nextValue, max(previousValue, mockEnvironment.minLogsUploadDelay))

            previousValue = nextValue
        }
    }

    func testWhenIncreasedOnce_itReturnsMaximumDelayOnceThenGoesBackToDefaultDelay() {
        var delay = DataUploadDelay(environment: mockEnvironment)
        delay.decrease()
        delay.increaseOnce()

        XCTAssertEqual(delay.nextUploadDelay(), mockEnvironment.maxLogsUploadDelay)
        XCTAssertEqual(delay.nextUploadDelay(), mockEnvironment.defaultLogsUploadDelay)
        XCTAssertEqual(delay.nextUploadDelay(), mockEnvironment.defaultLogsUploadDelay)
    }
}

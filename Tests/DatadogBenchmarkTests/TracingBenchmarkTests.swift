/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-2020 Datadog, Inc.
 */

import Datadog
import XCTest

class TracingBenchmarkTests: XCTestCase {
    private let operationName = "foobar-span"
    let tracer = Global.sharedTracer

    func testCreatingAndEndingOneSpan() {
        measure {
            let testSpan = tracer.startSpan(operationName: operationName)
            testSpan.finish()
        }
    }

    func testCreatingOneSpanWithBaggageItems() {
        measure {
            let testSpan = tracer.startSpan(operationName: operationName)
            (0..<16).forEach { index in
                testSpan.setBaggageItem(key: "a\(index)", value: "v\(index)")
            }
            testSpan.finish()
        }
    }

    func testCreatingOneSpanWithTags() {
        measure {
            let testSpan = tracer.startSpan(operationName: operationName)
            (0..<8).forEach { index in
                testSpan.setTag(key: "t\(index)", value: "v\(index)")
            }
            testSpan.finish()
        }
    }
}

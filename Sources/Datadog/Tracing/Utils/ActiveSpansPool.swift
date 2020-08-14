/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-2020 Datadog, Inc.
 */

import Foundation
import os.activity

/// This symbol is only accesible in Activity framework from Objective-C because uses a macro to create it, to use it from Swift
/// we must recreate whats done in the macro in Swift code.
internal let OS_ACTIVITY_CURRENT = unsafeBitCast(dlsym(UnsafeMutableRawPointer(bitPattern: -2), "_os_activity_current"), to: os_activity_t.self)

/// Helper class to get the current Span
internal class ActiveSpansPool {
    private var contextMap = [os_activity_id_t: DDSpan]()
    private let rlock = NSRecursiveLock()

    /// Returns the Span from the current context
    func getActiveSpan() -> DDSpan? {
        // We should try to traverse all hierarchy to locate the Span, but I could not find a way, just direct parent
        var parentIdent: os_activity_id_t = 0
        let activityIdent = os_activity_get_identifier(OS_ACTIVITY_CURRENT, &parentIdent)
        var returnSpan: DDSpan?
        rlock.lock()
        returnSpan = contextMap[activityIdent] ?? contextMap[parentIdent]
        rlock.unlock()
        return returnSpan
    }

    func addSpan(span: DDSpan, activityId: os_activity_id_t) {
        rlock.lock()
        contextMap[activityId] = span
        rlock.unlock()
    }

    func removeSpan(activityId: os_activity_id_t) {
        rlock.lock()
        contextMap[activityId] = nil
        rlock.unlock()
    }
}
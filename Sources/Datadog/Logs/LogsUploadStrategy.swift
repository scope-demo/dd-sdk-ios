/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-2020 Datadog, Inc.
 */

import Foundation

/// Prepares and owns logs upload stack.
internal struct LogsUploadStrategy {
    // MARK: - Initialization

    init(
        environment: Environment,
        appContext: AppContext,
        logsUploadURLProvider: UploadURLProvider,
        reader: FileReader,
        networkConnectionInfoProvider: NetworkConnectionInfoProviderType
    ) {
        let httpClient = HTTPClient()
        let httpHeaders = HTTPHeaders(appContext: appContext)
        let dataUploader = DataUploader(urlProvider: logsUploadURLProvider, httpClient: httpClient, httpHeaders: httpHeaders)

        let uploadQueue = DispatchQueue(
            label: "com.datadoghq.ios-sdk-logs-upload",
            target: .global(qos: .utility)
        )

        let uploadConditions: DataUploadConditions = {
            if let mobileDevice = appContext.mobileDevice {
                return DataUploadConditions(
                    batteryStatus: BatteryStatusProvider(mobileDevice: mobileDevice),
                    networkConnectionInfo: networkConnectionInfoProvider
                )
            } else {
                return DataUploadConditions(
                    batteryStatus: nil,
                    networkConnectionInfo: networkConnectionInfoProvider
                )
            }
        }()

        self.init(
            uploadWorker: DataUploadWorker(
                queue: uploadQueue,
                fileReader: reader,
                dataUploader: dataUploader,
                uploadConditions: uploadConditions,
                delay: DataUploadDelay(environment: environment)
            )
        )
    }

    init(uploadWorker: DataUploadWorker) {
        self.uploadWorker = uploadWorker
    }

    // MARK: - Strategy

    /// Uploads data to server with dynamic time intervals.
    let uploadWorker: DataUploadWorker
}

# iOS Log Collection

Send logs to Datadog from your iOS applications with [Datadog's `dd-sdk-ios` client-side logging library][1] and leverage the following features:

* Log to Datadog in JSON format natively.
* Use default and add custom attributes to each log sent.
* Record real client IP addresses and User-Agents.
* Leverage optimized network usage with automatic bulk posts.

**Note**: The `dd-sdk-ios` library supports all iOS versions 11+.

## Setup

1. Declare the library as a dependency depending on your package manager:

    {{< tabs >}}
    {{% tab "CocoaPods" %}}

You can use [CocoaPods][6] to install `dd-sdk-ios`:
```
pod 'DatadogSDK'
```

[6]: https://cocoapods.org/

    {{% /tab %}}
    {{% tab "Swift Package Manager (SPM)" %}}

To integrate using Apple's Swift Package Manager, add the following as a dependency to your `Package.swift`:
```swift
.package(url: "https://github.com/Datadog/dd-sdk-ios.git", .upToNextMajor(from: "1.0.0"))
```

    {{% /tab %}}
    {{% tab "Carthage" %}}

You can use [Carthage][7] to install `dd-sdk-ios`:
```
github "DataDog/dd-sdk-ios"
```

[7]: https://github.com/Carthage/Carthage

    {{% /tab %}}
    {{< /tabs >}}

2. Initialize the library with your application context and your [Datadog client token][2]. For security reasons, you must use a client token: you cannot use [Datadog API keys][3] to configure the `dd-sdk-ios` library as they would be exposed client-side in the iOS application IPA byte code. For more information about setting up a client token, see the [client token documentation][2]:

    {{< tabs >}}
    {{% tab "US" %}}

```swift
Datadog.initialize(
    appContext: .init(),
    configuration: Datadog.Configuration
        .builderUsing(clientToken: "<client_token>", environment: "<environment_name>")
        .set(serviceName: "app-name")
        .build()
)
```

    {{% /tab %}}
    {{% tab "EU" %}}

```swift
Datadog.initialize(
    appContext: .init(),
    configuration: Datadog.Configuration
        .builderUsing(clientToken: "<client_token>", environment: "<environment_name>")
        .set(serviceName: "app-name")
        .set(logsEndpoint: .eu)
        .build()
)
```

    {{% /tab %}}
    {{< /tabs >}}

     When writing your application, you can enable development logs. All internal messages in the SDK with a priority equal to or higher than the provided level are then logged to console logs.

    ```swift
    Datadog.verbosityLevel = .debug
    ```

3. Configure the `Logger`:

    ```swift
    logger = Logger.builder
        .sendNetworkInfo(true)
        .printLogsToConsole(true, usingFormat: .shortWith(prefix: "[iOS App] "))
        .build()
    ```

4. Send a custom log entry directly to Datadog with one of the following methods:

    ```swift
    logger.debug("A debug message.")
    logger.info("Some relevant information?")
    logger.notice("Have you noticed?")
    logger.warn("An important warning…")
    logger.error("An error was met!")
    logger.critical("Something critical happened!")
    ```

5. (Optional) - Provide a map of `attributes` alongside your log message to add attributes to the emitted log. Each entry of the map is added as an attribute.

    ```swift
    logger.info("Clicked OK", attributes: ["context": "onboarding flow"])
    ```

## Advanced logging

### Initialization

The following methods in `Logger.Builder` can be used when initializing the logger to send logs to Datadog:

| Method                           | Description                                                                                                                                                                                                                         |
|----------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `sendNetworkInfo(true)`    | Add `network.client.*` attributes to all logs. The data logged by default is: `reachability` (`yes`, `no`, `maybe`), `available_interfaces` (`wifi`, `cellular`, ...), `sim_carrier.name` (e.x. `AT&T - US`), `sim_carrier.technology` (`3G`, `LTE`, ...) and `sim_carrier.iso_country` (e.x. `US`). |
| `set(serviceName: "<SERVICE_NAME>")` | Set `<SERVICE_NAME>` as the value for the `service` [standard attribute][4] attached to all logs sent to Datadog.                                                                                                                        |
| `printLogsToConsole(true)`     | Set to `true` to send logs to the debugger console.                                                                                                                                                                                         |
| `sendLogsToDatadog(true)`    | Set to `true` to send logs to Datadog.                                                                                                                                                                                              |
| `set(loggerName: "<LOGGER_NAME>")`   | Set `<LOGGER_NAME>` as the value for the `logger.name` attribute attached to all logs sent to Datadog.                                                                                                                                   |
| `build()`                        | Build a new logger instance with all options set.                                                                                                                                                                                   |

### Global configuration

Find below methods to add/remove tags and attributes to all logs sent by a given logger.

#### Global Tags

##### Add Tags

Use the `addTag(withKey:value:)` method to add tags to all logs sent by a specific logger:

```swift
// This adds a tag "build_configuration:debug"
logger.addTag(withKey: "build_configuration", value: "debug")
```

**Note**: `<TAG_VALUE>` must be a `String`.

##### Remove Tags

Use the `removeTag(withKey:)` method to remove tags from all logs sent by a specific logger:

```swift
// This removes any tag starting with "build_configuration"
logger.removeTag(withKey: "build_configuration")
```

[Learn more about Datadog tags][5].

#### Global Attributes

##### Add attributes

By default, the following attributes are added to all logs sent by a logger:

* `http.useragent` and its extracted `device` and `OS` properties
* `network.client.ip` and its extracted geographical properties (`country`, `city`)
* `logger.version`, Datadog SDK version
* `logger.thread_name`, (`main`, `background`)
* `version`, client's app version extracted from `Info.plist`
* `environment`, the environment name used to initialize the SDK

Use the `addAttribute(forKey:value:)` method to add a custom attribute to all logs sent by a specific logger:

```swift
// This adds an attribute "device-model" with a string value
logger.addAttribute(forKey: "device-model", value: UIDevice.current.model)
```

**Note**: `<ATTRIBUTE_VALUE>` can be anything conforming to `Encodable` (`String`, `Date`, custom `Codable` data model, ...).

##### Remove attributes

Use the `removeAttribute(forKey:)` method to remove a custom attribute from all logs sent by a specific logger:

```swift
// This removes the attribute "device-model" from all further log send.
logger.removeAttribute(forKey: "device-model")

```

## Further Reading

{{< partial name="whats-next/whats-next.html" >}}

[1]: https://github.com/DataDog/dd-sdk-ios
[2]: https://docs.datadoghq.com/account_management/api-app-keys/#client-tokens
[3]: https://docs.datadoghq.com/account_management/api-app-keys/#api-keys
[4]: https://docs.datadoghq.com/logs/processing/attributes_naming_convention/
[5]: https://docs.datadoghq.com/tagging/

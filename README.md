# iOS WorkManager

iOS WorkManager is a wrapper around [BackgroundTasks](https://developer.apple.com/documentation/backgroundtasks)

> Currently only proccesing tasks are supported

It is useful to run periodic tasks, such as fetching remote data on a regular basis.

# Installation

# Setup

Before you can schedule a background task, you must register each task with a unique identifier in your project's `Info.plist`:

```xml
<key>BGTaskSchedulerPermittedIdentifiers</key>
	<array>
		<string>be.vrt.ios-workmanager.oneoffbackgroundtask</string>
		<string>be.vrt.ios-workmanager.recurringbackgroundtask</string>
	</array>
```

Also add required ***UIBackgroundModes***:

```xml
<key>UIBackgroundModes</key>
	<array>
		<string>processing</string>
	</array>
```

# Registering a task

Register a task inside your `AppDelegate` `didFinishLaunchingWithOptions` and provide a callback for when the task is executed:

```Swift
WorkManager.shared.registerTask(withIdentifier: "be.vrt.ios-workmanager.oneoffbackgroundtask") { task in
            self.handleOneOffTrigger(task: task as! BGProcessingTask)
        }
```

# Schedule a task

Two kinds of background tasks can be registered :
- **One off task** : runs only once
- **Periodic tasks** : runs indefinitely on a regular basis

To schedule a one off task:

```Swift
WorkManager.shared.scheduleOneOffTask(withIdentifier: "be.vrt.ios-workmanager.oneoffbackgroundtask", name: "database_clear")
```

To schedule a periodic task:

```Swift
WorkManager.shared.schedulePeriodicTask(withIdentifier: "be.vrt.ios-workmanager.recurringbackgroundtask", name: "update_something", frequency: 900)
```

# Properties

## Initial Delay

Indicates how along a task should wait before its first run.

```Swift
WorkManager.shared.schedulePeriodicTask(withIdentifier: "be.vrt.ios-workmanager.recurringbackgroundtask", name: "update_something", frequency: 900, initialDelay: 900)
```

## Existing Work Policy

Indicates the desired behaviour when the same task is scheduled more than once.  
The default is `KEEP`

## Constraints

```Swift
WorkManager.shared.schedulePeriodicTask(withIdentifier: "be.vrt.ios-workmanager.recurringbackgroundtask", name: "update_something", frequency: 900, constraints: [.requiresExternalPower, .requiresNetworkConnectivity])
```

## BackoffPolicy

Indicates the waiting strategy upon task failure.  
You can also specify the delay.

```Swift
WorkManager.shared.schedulePeriodicTask(withIdentifier: "be.vrt.ios-workmanager.recurringbackgroundtask", name: "update_something", frequency: 900,backoffPolicy: .exponential, backoffPolicyDelay: 500)
```

# Cancel a task

A task can be cancelled in different ways : 

## With identifier

```Swift
WorkManager.shared.cancelTask(withIdentifier identifier: "")
```

## With tag

```Swift
WorkManager.shared.cancelTask(withTag tag: "")
```

## All

```Swift
WorkManager.shared.cancelAllTasks()
```

# Example

See example project





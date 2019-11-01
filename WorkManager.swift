import BackgroundTasks

public class WorkManager {

    // MARK: Properties

    private let scheduler = WorkScheduler()
    private var scheduledTasks: [ScheduledTask] = []

    // MARK: Initialization

    public static let shared = WorkManager()
    private init() {}

    // MARK: Registering

    public func registerTask(withIdentifier identifier: String, onTrigger: @escaping (BGTask) -> ()) {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: identifier, using: nil) { task in
            onTrigger(task)
        }
    }

    // MARK: Scheduling

    public func scheduleOneOffTask(withIdentifier identifier: String,
                                           name: String,
                                           initialDelay: TimeInterval = 0.0,
                                           backoffPolicyDelay: TimeInterval = 0.0,
                                           tag: String? = nil,
                                           existingWorkPolicy: ExistingWorkPolicy? = nil,
                                           constraints: [Constraints]? = nil,
                                           backoffPolicy: BackoffPolicy? = nil,
                                           inputData: String? = nil) throws {
        try createTask(withIdentifier: identifier, name: name, frequency: nil, initialDelay: initialDelay, backoffPolicyDelay: backoffPolicyDelay, tag: tag, existingWorkPolicy: existingWorkPolicy, constraints: constraints, backoffPolicy: backoffPolicy, inputData: inputData)
    }

    public func schedulePeriodicTask(withIdentifier identifier: String,
                                                name: String,
                                                frequency: TimeInterval,
                                                initialDelay: TimeInterval = 0.0,
                                                backoffPolicyDelay: TimeInterval = 0.0,
                                                tag: String? = nil,
                                                existingWorkPolicy: ExistingWorkPolicy? = nil,
                                                constraints: [Constraints]? = nil,
                                                backoffPolicy: BackoffPolicy? = nil,
                                                inputData: String? = nil) throws {
    }

    // MARK: Creation

    private func createTask(withIdentifier identifier: String,
                            name: String,
                            frequency: TimeInterval?,
                            initialDelay: TimeInterval,
                            backoffPolicyDelay: TimeInterval,
                            tag: String?,
                            existingWorkPolicy: ExistingWorkPolicy?,
                            constraints: [Constraints]?,
                            backoffPolicy: BackoffPolicy?,
                            inputData: String?) throws {
        let task = Task(identifier: identifier,
                        name: name,
                        initialDelay: initialDelay,
                        backoffPolicyDelay: backoffPolicyDelay,
                        tag: tag,
                        frequency: frequency,
                        existingWorkPolicy: existingWorkPolicy,
                        constraints: constraints,
                        backoffPolicy: backoffPolicy,
                        inputData: inputData)

        try scheduler.scheduleTask(task) { request in
            scheduledTasks.append(ScheduledTask(task: task, request: request))
        }
    }

    // MARK: Callbacks

    public func taskDidFinish(_ task: BGTask, success: Bool) {
        guard let scheduledTask = getScheduledTask(forCompletedTask: task) else {
            // HANDLE ERROR
        }

        

        task.setTaskCompleted(success: success)
    }

    // MARK: Cleanup

    public func cancelAllTasks() {
    }

    // MARK: Helpers

    private func getScheduledTask(forCompletedTask completedTask: BGTask) -> ScheduledTask? {
        return scheduledTasks.filter { $0.request.identifier == completedTask.identifier }.first
    }
}

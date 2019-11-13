import BackgroundTasks

public class WorkManager {

    // MARK: Properties

    internal let scheduler = WorkScheduler()
    internal var scheduledTasks: [ScheduledTask] = []

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
                                           backoffPolicyDelay: TimeInterval = 900.0,
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
                                                backoffPolicyDelay: TimeInterval = 900.0,
                                                tag: String? = nil,
                                                existingWorkPolicy: ExistingWorkPolicy? = nil,
                                                constraints: [Constraints]? = nil,
                                                backoffPolicy: BackoffPolicy? = nil,
                                                inputData: String? = nil) throws {
        try createTask(withIdentifier: identifier, name: name, frequency: frequency, initialDelay: initialDelay, backoffPolicyDelay: backoffPolicyDelay, tag: tag, existingWorkPolicy: existingWorkPolicy, constraints: constraints, backoffPolicy: backoffPolicy, inputData: inputData)
    }

    // MARK: Callbacks

    public func taskDidFinish(_ task: BGTask, success: Bool) throws {
        task.setTaskCompleted(success: success)

        guard let scheduledTask = getScheduledTask(forCompletedTask: task) else {
            return
        }

        guard success else {
            try handleError(withScheduledTask: scheduledTask)
            return
        }

        try handleSuccess(withScheduledTask: scheduledTask)
    }

    // MARK: Success handlers

    private func handleSuccess(withScheduledTask scheduledTask: ScheduledTask) throws {
        if scheduledTask.task.isPeriodic {
            try handlePeriodicTaskSuccess(withScheduledTask: scheduledTask)
        } else {
            removeScheduledTask(scheduledTask)
        }
    }

    private func handlePeriodicTaskSuccess(withScheduledTask scheduledTask: ScheduledTask) throws {
        let previousTask = scheduledTask.task
        try createTask(withIdentifier: previousTask.identifier,
                           name: previousTask.name,
                           frequency: previousTask.frequency,
                           initialDelay: previousTask.frequency!,
                           backoffPolicyDelay: previousTask.backoffPolicyDelay,
                           tag: previousTask.tag,
                           existingWorkPolicy: previousTask.existingWorkPolicy,
                           constraints: previousTask.constraints,
                           backoffPolicy: previousTask.backoffPolicy,
                           inputData: previousTask.inputData)
    }

    // MARK: Error handlers

    private func handleError(withScheduledTask scheduledTask: ScheduledTask) throws {
        let previousTask = scheduledTask.task

        guard let backoffPolicy = previousTask.backoffPolicy else { return }

        var newTask = previousTask
        var delay = 0.0

        switch backoffPolicy {
        case .linear:
            delay = previousTask.initialDelay + previousTask.backoffPolicyDelay
        case .exponential:
            if previousTask.initialDelay == 0.0 {
                delay = previousTask.backoffPolicyDelay
            } else {
                delay = pow(previousTask.initialDelay, 2)
            }
        }

        newTask.initialDelay = delay

        try createTask(withIdentifier: newTask.identifier,
                           name: newTask.name,
                           frequency: newTask.frequency,
                           initialDelay: newTask.frequency!,
                           backoffPolicyDelay: newTask.backoffPolicyDelay,
                           tag: newTask.tag,
                           existingWorkPolicy: newTask.existingWorkPolicy,
                           constraints: newTask.constraints,
                           backoffPolicy: newTask.backoffPolicy,
                           inputData: newTask.inputData)
    }
}

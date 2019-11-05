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
        try createTask(withIdentifier: identifier, name: name, frequency: frequency, initialDelay: initialDelay, backoffPolicyDelay: backoffPolicyDelay, tag: tag, existingWorkPolicy: existingWorkPolicy, constraints: constraints, backoffPolicy: backoffPolicy, inputData: inputData)
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
        if let existingWorkPolicy = existingWorkPolicy, let _ = getScheduledTask(withIdentifier: identifier) {
            switch existingWorkPolicy {
            case .keep:
                return
            case .replace:
                cancelTask(withIdentifier: identifier)
            }
        }

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
        task.setTaskCompleted(success: success)

        guard let scheduledTask = getScheduledTask(forCompletedTask: task) else {
            // HANDLE ERROR
            return
        }

        guard success else {
            handleError(withScheduledTask: scheduledTask)
            return
        }

        handleSuccess(withScheduledTask: scheduledTask)
    }

    // MARK: Success handlers

    private func handleSuccess(withScheduledTask scheduledTask: ScheduledTask) {
        if scheduledTask.task.isPeriodic {
            handlePeriodicTaskSuccess(withScheduledTask: scheduledTask)
        } else {
            removeScheduledTask(scheduledTask)
        }
    }

    private func handlePeriodicTaskSuccess(withScheduledTask scheduledTask: ScheduledTask) {
        let previousTask = scheduledTask.task
        do {
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
        } catch {

        }
    }

    // MARK: Error handlers

    private func handleError(withScheduledTask scheduledTask: ScheduledTask) {
//        let previousTask = scheduledTask.task
//        let newTask = previousTask
//
//        if let backoffPolicy = previousTask.backoffPolicy {
//            var delay = 0.0
//            switch backoffPolicy {
//            case .linear:
//                delay += previousTask.backoffPolicyDelay
//            case .exponential:
//                delay = pow(previousTask.)
//                break
//            }
//        }
    }

    // MARK: Cleanup

    public func cancelAllTasks() {
        BGTaskScheduler.shared.cancelAllTaskRequests()
        scheduledTasks.removeAll()
    }

    public func cancelTask(withIdentifier identifier: String) {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: identifier)
        removeScheduledTask(withIdentifier: identifier)
    }

    public func cancelTask(withTag tag: String) {
        if let request = getRequest(withTag: tag) {
            BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: request.identifier)
            removeScheduledTask(withTag: tag)
        }
    }

    // MARK: Private helpers

    private func getScheduledTask(forCompletedTask completedTask: BGTask) -> ScheduledTask? {
        return scheduledTasks.filter { $0.task.identifier == completedTask.identifier }.first
    }

    private func getScheduledTask(withIdentifier identifier: String) -> ScheduledTask? {
        return scheduledTasks.filter { $0.task.identifier == identifier }.first
    }

    private func getScheduledTask(withTag tag: String) -> ScheduledTask? {
        return scheduledTasks.filter { $0.task.tag == tag }.first
    }

    private func getRequest(withTag tag: String) -> BGTaskRequest? {
        return getScheduledTask(withTag: tag)?.request
    }

    private func removeScheduledTask(_ scheduledTask: ScheduledTask) {
        if let index = scheduledTasks.firstIndex(where: { $0.task == scheduledTask.task}) {
            scheduledTasks.remove(at: index)
        }
    }

    private func removeScheduledTask(withIdentifier identifier: String) {
        if let scheduledTask = getScheduledTask(withIdentifier: identifier) {
            removeScheduledTask(scheduledTask)
        }
    }

    private func removeScheduledTask(withTag tag: String) {
        if let scheduledTask = getScheduledTask(withTag: tag) {
            removeScheduledTask(scheduledTask)
        }
    }
}

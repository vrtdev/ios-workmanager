import BackgroundTasks

extension WorkManager {

    // MARK: CRUD

    internal func createTask(withIdentifier identifier: String,
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

    internal func getScheduledTask(forCompletedTask completedTask: BGTask) -> ScheduledTask? {
        return scheduledTasks.first { $0.task.identifier == completedTask.identifier }
    }

    internal func getScheduledTask(withIdentifier identifier: String) -> ScheduledTask? {
        return scheduledTasks.first { $0.task.identifier == identifier }
    }

    internal func getScheduledTask(withTag tag: String) -> ScheduledTask? {
        return scheduledTasks.first { $0.task.tag == tag }
    }

    internal func getRequest(withTag tag: String) -> BGTaskRequest? {
        return getScheduledTask(withTag: tag)?.request
    }

    internal func removeScheduledTask(_ scheduledTask: ScheduledTask) {
        if let index = scheduledTasks.firstIndex(where: { $0.task == scheduledTask.task }) {
            scheduledTasks.remove(at: index)
        }
    }

    internal func removeScheduledTask(withIdentifier identifier: String) {
        if let scheduledTask = getScheduledTask(withIdentifier: identifier) {
            removeScheduledTask(scheduledTask)
        }
    }

    internal func removeScheduledTask(withTag tag: String) {
        if let scheduledTask = getScheduledTask(withTag: tag) {
            removeScheduledTask(scheduledTask)
        }
    }
}

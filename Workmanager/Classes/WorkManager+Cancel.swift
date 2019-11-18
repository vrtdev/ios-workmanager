import BackgroundTasks

extension WorkManager {

    // MARK: Cancel

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
}

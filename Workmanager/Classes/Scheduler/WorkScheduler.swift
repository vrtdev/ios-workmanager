import BackgroundTasks

class WorkScheduler {

    // MARK: Scheduling

    func scheduleTask(_ task: Task, onScheduled: (BGTaskRequest) -> Void) throws {
        let request = ProcessingRequestBuilder(identifier: task.identifier)
            .appendConstraints(task.constraints)
            .appendInitialDelay(task.initialDelay)
            .build()

        try submitRequest(request)
        onScheduled(request)
    }

    // MARK: Submit

    private func submitRequest(_ request: BGProcessingTaskRequest) throws {
        try BGTaskScheduler.shared.submit(request)
    }
}



import BackgroundTasks

class ProcessingRequestBuilder {

    // MARK: Private properties

    private let request: BGProcessingTaskRequest

    // MARK: Init

    init(identifier: String) {
        request = BGProcessingTaskRequest(identifier: identifier)
    }

    // MARK: Building blocks

    func appendInitialDelay(_ initialDelay: TimeInterval) -> ProcessingRequestBuilder {
        request.earliestBeginDate = Date(timeIntervalSinceNow: initialDelay)
        return self
    }

    func appendConstraints(_ constraints: [Constraints]?) -> ProcessingRequestBuilder {
        guard let constraints = constraints else { return self }

        for constraint in constraints {
            switch constraint {
            case .requiresExternalPower:
                request.requiresExternalPower = true
            case .requiresNetworkConnectivity:
                request.requiresNetworkConnectivity = true
            }
        }

        return self
    }

    func build() -> BGProcessingTaskRequest {
        return request
    }
}

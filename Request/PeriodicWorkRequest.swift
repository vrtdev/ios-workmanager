public struct PeriodicWorkRequest: PeriodicWorkRequestable {

    var frequency: TimeInterval
    var identifier: String
    var name: String
    var initialDelay: TimeInterval
    var backoffPolicyDelay: TimeInterval
    var tag: String?
    var existingWorkPolicy: ExistingWorkPolicy?
    var constraints: [Constraints]?
    var backoffPolicy: BackoffPolicy?
    var inputData: String?

    public init(identifier: String,
                name: String,
                initialDelay: TimeInterval,
                backoffPolicyDelay: TimeInterval,
                frequency: TimeInterval,
                tag: String? = nil,
                existingWorkPolicy: ExistingWorkPolicy? = nil,
                constraints: [Constraints]? = nil,
                backoffPolicy: BackoffPolicy? = nil,
                inputData: String? = nil) {
        self.identifier = identifier
        self.name = name
        self.initialDelay = initialDelay
        self.backoffPolicyDelay = backoffPolicyDelay
        self.frequency = frequency
        self.tag = tag
        self.existingWorkPolicy = existingWorkPolicy
        self.constraints = constraints
        self.backoffPolicy = backoffPolicy
        self.inputData = inputData
    }
}

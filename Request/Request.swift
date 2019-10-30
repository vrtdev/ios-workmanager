protocol Request {

    var identifier: String { get }
    var name: String { get }
    var initialDelay: TimeInterval { get }
    var backoffPolicyDelay: TimeInterval { get }
    var tag: String? { get }
    var existingWorkPolicy: ExistingWorkPolicy? { get }
    var constraints: [Constraints]? { get }
    var backoffPolicy: BackoffPolicy? { get }
    var inputData: String? { get }
}

typealias OneTimeWorkRequestable = Request

protocol PeriodicWorkRequestable: Request {

    var frequency: TimeInterval { get }
}

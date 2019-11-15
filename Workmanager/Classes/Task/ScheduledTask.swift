import BackgroundTasks

struct ScheduledTask: Hashable {

    let task: Task
    let request: BGTaskRequest

    func hash(into hasher: inout Hasher) {
        hasher.combine(task)
    }
}

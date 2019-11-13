import UIKit
import Workmanager
import BackgroundTasks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private lazy var viewController: ViewController = ViewController()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        WorkManager.shared.registerTask(withIdentifier: "be.vrt.ios-workmanager.oneoffbackgroundtask") { task in
            self.handleOneOffTrigger(task: task as! BGProcessingTask)
        }

        WorkManager.shared.registerTask(withIdentifier: "be.vrt.ios-workmanager.recurringbackgroundtask") { task in
            self.handlePeriodicTrigger(task: task as! BGProcessingTask)
        }


        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .black
        window?.makeKeyAndVisible()

        window?.rootViewController = UINavigationController(rootViewController: viewController)

        return true
    }
}

extension AppDelegate {

    private func handleOneOffTrigger(task: BGProcessingTask) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController.updateOneOffBallColor(toColor: UIColor.random)
        }

        do {
            try WorkManager.shared.taskDidFinish(task, success: true)
        } catch {

        }
    }

    private func handlePeriodicTrigger(task: BGProcessingTask) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController.updateRecurringBallColor(toColor: UIColor.random)
        }

        do {
            try WorkManager.shared.taskDidFinish(task, success: true)
        } catch {

        }
    }
}

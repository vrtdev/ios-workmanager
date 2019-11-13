import UIKit
import Workmanager
import BackgroundTasks

class ViewController: UIViewController {

    // MARK: UI

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        return stackView
    }()

    private let explanationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.text = "Registering a task will randomly change the corresponding ball's backgroundcolor."
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()

    private let oneTimeTaskLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.text = "One Off Tasks"
        label.textColor = .black
        return label
    }()

    private lazy var registerOneTimeWorkTaskButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.addTarget(self, action: #selector(didTapRegisterOneOffTaskButton(_:)), for: .touchUpInside)
        button.setTitle("Register one off task", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let oneoffBall: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        view.layer.cornerRadius = 30
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let periodicTaskLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.text = "Periodic Tasks"
        label.textColor = .black
        return label
    }()

    private lazy var registerPeriodicWorkTaskButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.addTarget(self, action: #selector(didTapRegisterPeriodicTaskButton(_:)), for: .touchUpInside)
        button.setTitle("Register periodic task", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let recurringBall: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        view.layer.cornerRadius = 30
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: Lifecycle

    override func loadView() {
        super.loadView()

        view.backgroundColor = .white

        let margins = view.layoutMarginsGuide

        stackView.addArrangedSubview(explanationLabel)
        stackView.setCustomSpacing(40, after: explanationLabel)
        stackView.addArrangedSubview(oneTimeTaskLabel)
        stackView.addArrangedSubview(registerOneTimeWorkTaskButton)
        stackView.addArrangedSubview(oneoffBall)
        oneoffBall.widthAnchor.constraint(equalToConstant: 60).isActive = true
        oneoffBall.heightAnchor.constraint(equalToConstant: 60).isActive = true
        stackView.setCustomSpacing(40, after: oneoffBall)
        stackView.addArrangedSubview(periodicTaskLabel)
        stackView.addArrangedSubview(registerPeriodicWorkTaskButton)
        stackView.addArrangedSubview(recurringBall)
        recurringBall.widthAnchor.constraint(equalToConstant: 60).isActive = true
        recurringBall.heightAnchor.constraint(equalToConstant: 60).isActive = true

        view.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 20).isActive = true
        stackView.leftAnchor.constraint(equalTo: margins.leftAnchor, constant: 0).isActive = true
        stackView.rightAnchor.constraint(equalTo: margins.rightAnchor, constant: 0).isActive = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "VRT iOS WorkManager"
    }

    // MARK: Actions


    @objc private func didTapRegisterOneOffTaskButton(_ sender: UIButton) {
        do {
            try WorkManager.shared.scheduleOneOffTask(withIdentifier: "be.vrt.ios-workmanager.oneoffbackgroundtask", name: "", existingWorkPolicy: .keep)
        } catch {
        }
    }

    @objc private func didTapRegisterPeriodicTaskButton(_ sender: UIButton) {
        do {
            try WorkManager.shared.schedulePeriodicTask(withIdentifier: "be.vrt.ios-workmanager.recurringbackgroundtask", name: "", frequency: 60)
        } catch {
        }
    }

    // MARK: Public color setters

    func updateOneOffBallColor(toColor color: UIColor) {
        oneoffBall.backgroundColor = color
    }

    func updateRecurringBallColor(toColor color: UIColor) {
        recurringBall.backgroundColor = color
    }
}


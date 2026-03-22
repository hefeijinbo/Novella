import Flutter
import UIKit

class iOS26ActionGroupViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return iOS26ActionGroupView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger
        )
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }
}

class iOS26ActionGroupView: NSObject, FlutterPlatformView {
    private let containerView: UIView
    private let blurView: UIVisualEffectView
    private let stackView: UIStackView
    private let channel: FlutterMethodChannel
    private var items: [[String: Any]] = []
    private var foregroundColor: UIColor = .white
    private var isDark: Bool = false

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        containerView = UIView(frame: frame)
        if #available(iOS 13.0, *) {
            blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        } else {
            blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        }
        stackView = UIStackView(frame: frame)
        channel = FlutterMethodChannel(
            name: "adaptive_platform_ui/ios26_action_group_\(viewId)",
            binaryMessenger: messenger
        )

        super.init()

        if let params = args as? [String: Any] {
            if let parsedItems = params["items"] as? [[String: Any]] {
                items = parsedItems
            }
            if let argb = params["foregroundColor"] as? Int {
                foregroundColor = UIColor(argb: argb)
            }
            isDark = params["isDark"] as? Bool ?? false
        }

        setupContainer()
        rebuildItems()
    }

    func view() -> UIView {
        containerView
    }

    private func setupContainer() {
        containerView.backgroundColor = .clear
        if #available(iOS 13.0, *) {
            containerView.overrideUserInterfaceStyle = isDark ? .dark : .light
        }

        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.clipsToBounds = true
        blurView.layer.cornerRadius = 24
        if #available(iOS 13.0, *) {
            blurView.layer.cornerCurve = .continuous
        }

        if #available(iOS 13.0, *) {
            blurView.effect = UIBlurEffect(style: .systemUltraThinMaterial)
            blurView.contentView.backgroundColor = UIColor.white.withAlphaComponent(isDark ? 0.03 : 0.08)
        }

        containerView.addSubview(blurView)

        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: containerView.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 0

        blurView.contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -12),
            stackView.topAnchor.constraint(equalTo: blurView.contentView.topAnchor, constant: 6),
            stackView.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -6),
        ])
    }

    private func rebuildItems() {
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        for (index, item) in items.enumerated() {
            stackView.addArrangedSubview(makeItemView(item: item, index: index))

            if index != items.count - 1 {
                let divider = UIView()
                divider.translatesAutoresizingMaskIntoConstraints = false
                divider.backgroundColor = foregroundColor.withAlphaComponent(isDark ? 0.18 : 0.24)
                NSLayoutConstraint.activate([
                    divider.widthAnchor.constraint(equalToConstant: 0.5),
                    divider.heightAnchor.constraint(equalToConstant: 22),
                ])
                stackView.addArrangedSubview(divider)
            }
        }
    }

    private func makeItemView(item: [String: Any], index: Int) -> UIView {
        let loading = item["loading"] as? Bool ?? false
        let enabled = item["enabled"] as? Bool ?? true

        if loading {
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            let indicator = UIActivityIndicatorView(style: .medium)
            indicator.translatesAutoresizingMaskIntoConstraints = false
            indicator.color = foregroundColor
            indicator.startAnimating()
            container.addSubview(indicator)
            NSLayoutConstraint.activate([
                container.widthAnchor.constraint(equalToConstant: 40),
                container.heightAnchor.constraint(equalToConstant: 36),
                indicator.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                indicator.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            ])
            return container
        }

        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = index
        button.tintColor = foregroundColor
        button.isEnabled = enabled

        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.baseForegroundColor = foregroundColor
            config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10)

            if let title = item["title"] as? String, !title.isEmpty {
                config.title = title
                var attributedTitle = AttributedString(title)
                attributedTitle.font = .systemFont(ofSize: 15, weight: .semibold)
                config.attributedTitle = attributedTitle
            } else if let icon = item["icon"] as? String,
                      let image = UIImage(systemName: icon)?.applyingSymbolConfiguration(
                        UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
                      ) {
                config.image = image
            }

            button.configuration = config
        } else {
            if let title = item["title"] as? String, !title.isEmpty {
                button.setTitle(title, for: .normal)
            } else if let icon = item["icon"] as? String {
                button.setImage(UIImage(systemName: icon), for: .normal)
            }
        }

        button.addTarget(self, action: #selector(itemTapped(_:)), for: .touchUpInside)

        let hasTitle = (item["title"] as? String)?.isEmpty == false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 36),
            button.widthAnchor.constraint(equalToConstant: hasTitle ? 68 : 40),
        ])

        return button
    }

    @objc private func itemTapped(_ sender: UIButton) {
        channel.invokeMethod("onItemTapped", arguments: ["index": sender.tag])
    }
}

// Copyright (c) 2020 Claus Jørgensen
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI
import SafariServices

/// A view for displaying web content in a Safari-like interface with some of Safari’s features.
///
/// Example usage:
/// ```
/// SafariView(url: URL(string: "https://www.apple.com")!)
///     .preferredBarTintColor(.white)
///     .preferredControlTintColor(.black)
///     .dismissButtonStyle(.done)
///     .barCollapsingEnabled(true)
///     .entersReaderIfAvailable(false)
/// ```
public struct SafariView: UIViewControllerRepresentable {
    public enum DismissButtonStyle {
        case done
        case close
        case cancel
    }

    private class State: ObservableObject {
        var preferredBarTintColor: UIColor?
        var preferredControlTintColor: UIColor?
        var dismissButtonStyle: SFSafariViewController.DismissButtonStyle = .done
        var entersReaderIfAvailable = false
        var barCollapsingEnabled = true
    }

    @Binding private var state: State

    private let url: URL

    public init(url: URL) {
        self.url = url

        _state = .constant(State())
    }

    public func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = state.entersReaderIfAvailable
        configuration.barCollapsingEnabled = state.barCollapsingEnabled

        return SFSafariViewController(url: url, configuration: configuration)
    }

    public func updateUIViewController(_ uiViewController: SFSafariViewController,
                                       context: UIViewControllerRepresentableContext<SafariView>) {
        uiViewController.preferredBarTintColor = state.preferredBarTintColor
        uiViewController.preferredControlTintColor = state.preferredControlTintColor
        uiViewController.dismissButtonStyle = state.dismissButtonStyle
    }
}

public extension SafariView {
    /// Sets the preferred color to tint the background of the navigation bar and toolbar.
    ///
    /// If `SafariView` is in Private Browsing mode or is displaying an anti-phishing
    /// warning page, this color will be ignored.
    func preferredBarTintColor(_ color: UIColor?) -> Self {
        state.preferredBarTintColor = color
        return self
    }

    /// Sets the preferred color to tint the control buttons on the navigation bar and toolbar.
    ///
    /// If `SafariView` is in Private Browsing mode or is displaying an anti-phishing
    /// warning page, this color will be ignored.
    func preferredControlTintColor(_ color: UIColor?) -> Self {
        state.preferredControlTintColor = color
        return self
    }

    /// Sets the style of dismiss button to use in the navigation bar to close `SafariView`.
    ///
    /// The default value is `.done`, which makes the button title the localized string "Done".
    ///
    /// You can use other values such as "Close" to provide consistency with your app.
    /// "Cancel" is ideal when using `SafariView` to log in to an external service.
    ///
    /// All values will show a string localized to the user's locale.
    func dismissButtonStyle(_ style: DismissButtonStyle) -> Self {
        switch style {
        case .done:
            state.dismissButtonStyle = .done
        case .close:
            state.dismissButtonStyle = .close
        case .cancel:
            state.dismissButtonStyle = .cancel
        }
        return self
    }

    /// Indicates if `SafariView` should automatically show the Reader version of web pages.
    /// This will only happen when Safari Reader is available on a web page.
    func entersReaderIfAvailable(_ value: Bool) -> Self {
        state.entersReaderIfAvailable = value
        return self
    }

    /// Indicates if `SafariView` should enable collapsing of the navigation bar
    /// and hiding of the bottom toolbar when the user scrolls web content.
    func barCollapsingEnabled(_ value: Bool) -> Self {
        state.barCollapsingEnabled = value
        return self
    }
}

struct SafariView_Preview: PreviewProvider {
    static var previews: some View {
        SafariView(url: URL(string: "https://www.apple.com")!)
            .preferredBarTintColor(.label)
            .preferredControlTintColor(.systemBackground)
            .dismissButtonStyle(.done)
            .barCollapsingEnabled(true)
            .entersReaderIfAvailable(false)
    }
}

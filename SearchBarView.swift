// Copyright (c) 2020 Claus Jørgensen
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI
import UIKit

/// A specialized view for receiving search-related information from the user.
///
/// Example usage:
/// ```
/// SearchBarView(placeholder: "Search", value: $searchText)
///    .searchBarStyle(.minimal)
/// ```
public struct SearchBarView: UIViewRepresentable {
    /// Bar style for the search bar appearance.
    public enum BarStyle {
        /// Use the default style normally associated with the given view. For example, navigation bars typically use a white background with dark content.
        case `default`
        /// Use a black background with light content.
        case black
    }

    // Specifies whether the search bar has a background.
    public enum Style {
        /// The search bar has the default style.
        case `default`
        /// The search bar has a translucent background, and the search field is opaque.
        case prominent
        /// The search bar has no background, and the search field is translucent.
        case minimal
    }

    private var onEditingChanged: (Bool) -> Void
    private var searchButtonClicked: () -> Void
    private var bookmarkButtonClicked: () -> Void
    private var cancelButtonClicked: () -> Void
    private var resultsListButtonClicked: () -> Void
    private var shouldChangeTextIn: (Range<Int>, String) -> (Bool)
    private var placeholder: String

    private class State: ObservableObject {
        var barStyle: UIBarStyle = .default
        var prompt: String?
        var showsBookmarkButton = false
        var showsCancelButton = false
        var showsSearchResultsButton = false
        var isSearchResultsButtonSelected = false
        var barTintColor: UIColor?
        var searchBarStyle: UISearchBar.Style = .default
        var isTranslucent = false
        var scopeButtonTitles: [String]?
        var showsScopeBar = false
        var inputAccessoryView: UIView?
        var backgroundImage: UIImage?
        var scopeBarBackgroundImage: UIImage?
        var searchFieldBackgroundPositionAdjustment: UIOffset = .zero
        var searchTextPositionAdjustment: UIOffset = .zero
    }

    @Binding private var state: State

    /// The index of the selected scope button.
    @Binding public var selectedScopeButtonIndex: Int

    /// The current or starting search text
    @Binding public var value: String

    /// Whether if editing should begin in the search bar.
    @Binding public var shouldBeginEditing: Bool

    /// Whether if editing should end in the search bar.
    @Binding public var shouldEndEditing: Bool

    /// - parameters:
    ///   - placeholder: The string that is displayed when there is no other search text.
    ///   - value: The current or starting search text
    ///   - shouldBeginEditing: Whether if editing should begin in the search bar.
    ///   - shouldEndEditing: Whether if editing should end in the search bar.
    ///   - selectedScopeButtonIndex: The index of the selected scope button.
    ///   - shouldChangeTextIn: Whether if text in a specified range should be replaced with given text.
    ///   - onEditingChanged: An action thats called when the user begins editing `value` and after the user finishes editing `value`.
    ///   - searchButtonClicked: An action thats called when the user tapped on the search button.
    ///   - bookmarkButtonClicked: An action thats called when the user tapped on the bookmark button.
    ///   - cancelButtonClicked: An action thats called when the user tapped on the cancel button.
    ///   - resultsListButtonClicked: An action thats called when the user tapped on the search results list button.
    public init(placeholder: String = "",
                value: Binding<String>,
                shouldBeginEditing: Binding<Bool> = .constant(true),
                shouldEndEditing: Binding<Bool> = .constant(false),
                selectedScopeButtonIndex: Binding<Int> = .constant(0),
                shouldChangeTextIn: @escaping (Range<Int>, String) -> (Bool) = { _, _ in true },
                onEditingChanged: @escaping (Bool) -> Void = { _ in },
                searchButtonClicked: @escaping () -> Void = {},
                bookmarkButtonClicked: @escaping () -> Void = {},
                cancelButtonClicked: @escaping () -> Void = {},
                resultsListButtonClicked: @escaping () -> Void = {}) {
        self.placeholder = placeholder
        self.shouldChangeTextIn = shouldChangeTextIn
        self.onEditingChanged = onEditingChanged
        self.searchButtonClicked = searchButtonClicked
        self.bookmarkButtonClicked = bookmarkButtonClicked
        self.cancelButtonClicked = cancelButtonClicked
        self.resultsListButtonClicked = resultsListButtonClicked

        _value = value
        _shouldBeginEditing = shouldBeginEditing
        _shouldEndEditing = shouldEndEditing
        _selectedScopeButtonIndex = selectedScopeButtonIndex
        _state = .constant(State())
    }

    public func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        return searchBar
    }

    public func updateUIView(_ searchBar: UISearchBar, context: Context) {
        searchBar.text = value
        searchBar.selectedScopeButtonIndex = selectedScopeButtonIndex
        searchBar.barStyle = state.barStyle
        searchBar.prompt = state.prompt
        searchBar.showsBookmarkButton = state.showsBookmarkButton
        searchBar.showsCancelButton = state.showsCancelButton
        searchBar.showsSearchResultsButton = state.showsSearchResultsButton
        searchBar.isSearchResultsButtonSelected = state.isSearchResultsButtonSelected
        searchBar.barTintColor = state.barTintColor
        searchBar.searchBarStyle = state.searchBarStyle
        searchBar.isTranslucent = state.isTranslucent
        searchBar.scopeButtonTitles = state.scopeButtonTitles
        searchBar.showsScopeBar = state.showsScopeBar
        searchBar.inputAccessoryView = state.inputAccessoryView
        searchBar.backgroundImage = state.backgroundImage
        searchBar.scopeBarBackgroundImage = state.scopeBarBackgroundImage
        searchBar.searchFieldBackgroundPositionAdjustment = state.searchFieldBackgroundPositionAdjustment
        searchBar.searchTextPositionAdjustment = state.searchTextPositionAdjustment
    }

    public func makeCoordinator() -> SearchBarView.Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, UISearchBarDelegate {
        private let parent: SearchBarView

        fileprivate init(_ parent: SearchBarView) {
            self.parent = parent
        }

        public func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
            return parent.shouldBeginEditing
        }

        public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            parent.onEditingChanged(true)
        }

        public func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
            return parent.shouldEndEditing
        }

        public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            parent.onEditingChanged(false)
        }

        public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            parent.value = searchText
        }

        public func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            guard let range = Range(range) else { return false }
            return parent.shouldChangeTextIn(range, text)
        }

        public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            parent.searchButtonClicked()
        }

        public func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
            parent.bookmarkButtonClicked()
        }

        public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            parent.cancelButtonClicked()
        }

        public func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
            parent.resultsListButtonClicked()
        }

        public func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
            parent.selectedScopeButtonIndex = selectedScope
        }
    }
}

public extension SearchBarView {
    /// Sets the bar style that specifies the search bar’s appearance.
    func barStyle(_ style: BarStyle) -> Self {
        switch style {
        case .default:
            state.barStyle = .default
        case .black:
            state.barStyle = .black
        }
        return self
    }

    /// Sets a single line of text displayed at the top of the search bar.
    func prompt(_ text: String?) -> Self {
        state.prompt = text
        return self
    }

    // Sets whether the bookmark button is displayed.
    func showsBookmarkButton(_ value: Bool) -> Self {
        state.showsBookmarkButton = value
        return self
    }

    // Sets whether the cancel button is displayed.
    func showsCancelButton(_ value: Bool) -> Self {
        state.showsCancelButton = value
        return self
    }

    // Sets whether the search results button is displayed.
    func showsSearchResultsButton(_ value: Bool) -> Self {
        state.showsSearchResultsButton = value
        return self
    }

    /// Sets whether the search results button is selected.
    func isSearchResultsButtonSelected(_ value: Bool) -> Self {
        state.isSearchResultsButtonSelected = value
        return self
    }

    /// Sets the tint color to apply to the search bar background.
    func barTintColor(_ color: UIColor?) -> Self {
        state.barTintColor = color
        return self
    }

    /// Sets a search bar style that specifies the search bar’s appearance.
    func searchBarStyle(_ style: Style) -> Self {
        switch style {
        case .default:
            state.searchBarStyle = .default
        case .prominent:
            state.searchBarStyle = .prominent
        case .minimal:
            state.searchBarStyle = .minimal
        }
        return self
    }

    /// Sets whether the search bar is translucent or not.
    func isTranslucent(_ value: Bool) -> Self {
        state.isTranslucent = value
        return self
    }

    /// Sets an array of strings indicating the titles of the scope buttons.
    func scopeButtonTitles(_ titles: [String]?) -> Self {
        state.scopeButtonTitles = titles
        return self
    }

    /// Sets whether the scope bar is displayed
    func showsScopeBar(_ value: Bool) -> Self {
        state.showsScopeBar = value
        return self
    }

    /// Sets a custom input accessory view for the keyboard of the search bar.
    func inputAccessoryView<TView>(@ViewBuilder _ content: () -> TView) -> Self where TView: View {
        let hostingViewController = UIHostingController(rootView: content())
        hostingViewController.view.sizeToFit()
        return self.inputAccessoryView(hostingViewController.view)
    }

    /// Sets a custom input accessory view for the keyboard of the search bar.
    func inputAccessoryView(_ inputAccessoryView: UIView?) -> Self {
        state.inputAccessoryView = inputAccessoryView
        return self
    }

    /// Sets the background image for the search bar.
    func backgroundImage(_ image: UIImage?) -> Self {
        state.backgroundImage = image
        return self
    }

    /// Sets the background image for the scope bar.
    func scopeBarBackgroundImage(_ image: UIImage?) -> Self {
        state.scopeBarBackgroundImage = image
        return self
    }

    /// Sets offset of the search text field background in the search bar.
    func searchFieldBackgroundPositionAdjustment(_ offset: UIOffset) -> Self {
        state.searchFieldBackgroundPositionAdjustment = offset
        return self
    }

    /// Sets offset of the text within the search text field background.
    func searchTextPositionAdjustment(_ offset: UIOffset) -> Self {
        state.searchTextPositionAdjustment = offset
        return self
    }
}

struct SearchBarView_Preview: PreviewProvider {
    static var previews: some View {
        SearchBarView(placeholder: "Search", value: .constant(""))
            .searchBarStyle(.minimal)
    }
}

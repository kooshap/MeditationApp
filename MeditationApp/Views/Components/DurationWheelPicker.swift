import SwiftUI
import UIKit

// Native UIPickerView wheel — gives OS-level haptics and scroll feel for free
struct DurationWheelPicker: UIViewRepresentable {
    @Binding var hours: Int
    @Binding var minutes: Int
    @Binding var seconds: Int

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.delegate   = context.coordinator
        picker.dataSource = context.coordinator
        picker.backgroundColor = .clear

        // The picker lives inside SwiftUI's ScrollView. Dragging a wheel past its last row
        // (e.g. beyond 23h) lets that outer scroll view take over the pan, which can leave
        // every wheel unresponsive until touches are cancelled by backgrounding the app.
        // This recognizer never acts; it just makes outer scroll pans wait for it to fail,
        // and it can't fail while the finger started on the picker.
        let guardPan = UIPanGestureRecognizer()
        guardPan.cancelsTouchesInView = false
        guardPan.delegate = context.coordinator
        picker.addGestureRecognizer(guardPan)

        picker.selectRow(hours,   inComponent: 0, animated: false)
        picker.selectRow(minutes, inComponent: 1, animated: false)
        picker.selectRow(seconds, inComponent: 2, animated: false)
        return picker
    }

    func updateUIView(_ uiView: UIPickerView, context: Context) {
        context.coordinator.parent = self
        if uiView.selectedRow(inComponent: 0) != hours   { uiView.selectRow(hours,   inComponent: 0, animated: false) }
        if uiView.selectedRow(inComponent: 1) != minutes { uiView.selectRow(minutes, inComponent: 1, animated: false) }
        if uiView.selectedRow(inComponent: 2) != seconds { uiView.selectRow(seconds, inComponent: 2, animated: false) }
    }

    // MARK: — Coordinator

    final class Coordinator: NSObject, UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate {
        var parent: DurationWheelPicker
        private let haptic = UISelectionFeedbackGenerator()

        init(_ parent: DurationWheelPicker) {
            self.parent = parent
            super.init()
            haptic.prepare()
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int { 3 }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            component == 0 ? 24 : 60
        }

        func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
            let labels = ["\(row)h", String(format: "%02dm", row), String(format: "%02ds", row)]
            return NSAttributedString(
                string: labels[component],
                attributes: [
                    .foregroundColor: UIColor.white,
                    .font: UIFont.systemFont(ofSize: 22, weight: .thin)
                ]
            )
        }

        func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat { 88 }
        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat { 48 }

        // MARK: Guard pan

        // Let the wheels' own scroll pans run alongside the guard
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                               shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
            true
        }

        // Outer scroll views (anything not inside the picker) must wait for the guard to fail
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                               shouldBeRequiredToFailBy other: UIGestureRecognizer) -> Bool {
            guard let picker = gestureRecognizer.view,
                  let otherView = other.view,
                  otherView is UIScrollView else { return false }
            return !otherView.isDescendant(of: picker)
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            haptic.selectionChanged()
            switch component {
            case 0: parent.hours   = row
            case 1: parent.minutes = row
            case 2: parent.seconds = row
            default: break
            }
        }
    }
}

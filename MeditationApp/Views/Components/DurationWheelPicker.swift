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

    final class Coordinator: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
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

import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var overlay: SelectionOverlay?
    private let menu = NSMenu()

    private static let dialogIcon: NSImage = {
        NSImage(size: NSSize(width: 128, height: 128), flipped: false) { rect in
            NSColor.systemBlue.setFill()
            NSBezierPath(roundedRect: rect, xRadius: 26, yRadius: 26).fill()

            if let qr = NSImage(systemSymbolName: "qrcode", accessibilityDescription: nil)?
                .withSymbolConfiguration(.init(pointSize: 70, weight: .regular))?
                .withSymbolConfiguration(.init(paletteColors: [.white])) {
                let size = qr.size
                qr.draw(in: NSRect(x: (rect.width - size.width) / 2, y: (rect.height - size.height) / 2 + 6, width: size.width, height: size.height))
            }

            let badge = "GC" as NSString
            let attrs: [NSAttributedString.Key: Any] = [.font: NSFont.boldSystemFont(ofSize: 20), .foregroundColor: NSColor.white]
            let badgeSize = badge.size(withAttributes: attrs)
            badge.draw(at: NSPoint(x: rect.width - badgeSize.width - 10, y: 8), withAttributes: attrs)
            return true
        }
    }()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(systemSymbolName: "qrcode.viewfinder", accessibilityDescription: "QR Lector")
        statusItem.button?.target = self
        statusItem.button?.action = #selector(statusItemClicked)
        statusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])

        menu.addItem(withTitle: "Iniciar Scan", action: #selector(startScan), keyEquivalent: "").target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: "Salir", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    }

    @objc private func statusItemClicked() {
        guard let event = NSApp.currentEvent, let button = statusItem.button else { return }
        if event.type == .rightMouseUp || event.modifierFlags.contains(.control) {
            menu.popUp(positioning: nil, at: NSPoint(x: 0, y: button.bounds.maxY), in: button)
        } else {
            startScan()
        }
    }

    @objc private func startScan() {
        guard let screen = NSScreen.main else { return }
        overlay = SelectionOverlay(screen: screen) { [weak self] screenRect in
            self?.overlay = nil
            guard let screenRect else { return }
            self?.handleCapturedRegion(screenRect)
        }
        overlay?.begin()
    }

    private func handleCapturedRegion(_ screenRect: CGRect) {
        guard let text = QRScan.scan(rect: screenRect) else {
            showAlert(title: "Sin resultado", message: "No se encontró ningún código QR en el área seleccionada.", offerCopy: false)
            return
        }
        showAlert(title: "QR detectado", message: text, offerCopy: true)
    }

    private func showAlert(title: String, message: String, offerCopy: Bool) {
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.messageText = title
        alert.icon = Self.dialogIcon

        let field = NSTextField(wrappingLabelWithString: message)
        field.isSelectable = true
        field.isEditable = false
        field.font = .systemFont(ofSize: 12)
        field.preferredMaxLayoutWidth = 300
        alert.accessoryView = field

        alert.addButton(withTitle: "Cerrar")
        if offerCopy {
            let copyButton = alert.addButton(withTitle: "Copiar")
            copyButton.image = NSImage(systemSymbolName: "doc.on.doc", accessibilityDescription: "Copiar")
            copyButton.imagePosition = .imageLeading
        }

        let response = alert.runModal()
        if offerCopy && response == .alertSecondButtonReturn {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(message, forType: .string)
        }
    }
}

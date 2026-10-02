import AppKit

/// Ventana transparente a pantalla completa que deja arrastrar un rectángulo con el mouse.
final class SelectionOverlay {
    private var window: NSWindow!
    private let onComplete: (CGRect?) -> Void

    init(screen: NSScreen, onComplete: @escaping (CGRect?) -> Void) {
        self.onComplete = onComplete
        window = NSWindow(contentRect: screen.frame, styleMask: .borderless, backing: .buffered, defer: false)
        window.level = .screenSaver
        window.isOpaque = false
        window.backgroundColor = .clear
        window.ignoresMouseEvents = false
        window.contentView = SelectionView(frame: NSRect(origin: .zero, size: screen.frame.size)) { [weak self] viewRect in
            self?.finish(viewRect)
        }
    }

    func begin() {
        NSCursor.crosshair.set()
        window.makeKeyAndOrderFront(nil)
    }

    private func finish(_ viewRect: CGRect?) {
        NSCursor.arrow.set()
        window.orderOut(nil)
        guard let viewRect, viewRect.width > 4, viewRect.height > 4 else {
            onComplete(nil)
            return
        }
        // AppKit (origen abajo-izquierda) -> coordenadas Quartz globales (origen arriba-izquierda)
        // que espera CGWindowListCreateImage.
        let windowFrame = window.frame
        let globalAppKitRect = viewRect.offsetBy(dx: windowFrame.origin.x, dy: windowFrame.origin.y)
        let primaryHeight = NSScreen.screens.first?.frame.height ?? windowFrame.height
        let quartzRect = CGRect(
            x: globalAppKitRect.origin.x,
            y: primaryHeight - globalAppKitRect.origin.y - globalAppKitRect.height,
            width: globalAppKitRect.width,
            height: globalAppKitRect.height
        )
        onComplete(quartzRect)
    }
}

private final class SelectionView: NSView {
    private var startPoint: NSPoint?
    private var currentRect: NSRect?
    private let onFinish: (CGRect?) -> Void

    init(frame: NSRect, onFinish: @escaping (CGRect?) -> Void) {
        self.onFinish = onFinish
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func mouseDown(with event: NSEvent) {
        startPoint = convert(event.locationInWindow, from: nil)
        currentRect = nil
    }

    override func mouseDragged(with event: NSEvent) {
        guard let start = startPoint else { return }
        let point = convert(event.locationInWindow, from: nil)
        currentRect = NSRect(
            x: min(start.x, point.x), y: min(start.y, point.y),
            width: abs(point.x - start.x), height: abs(point.y - start.y)
        )
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        onFinish(currentRect)
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { onFinish(nil) } // Esc
    }

    override var acceptsFirstResponder: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.black.withAlphaComponent(0.25).setFill()
        bounds.fill()
        guard let rect = currentRect else { return }
        NSColor.clear.setFill()
        rect.fill(using: .copy) // "recorta" la zona seleccionada del velo oscuro
        NSColor.white.setStroke()
        let path = NSBezierPath(rect: rect)
        path.lineWidth = 1.5
        path.stroke()
    }
}

import AppKit

let app = NSApplication.shared
app.setActivationPolicy(.accessory) // sin ícono en el Dock, solo barra de menú
let delegate = AppDelegate()
app.delegate = delegate
app.run()

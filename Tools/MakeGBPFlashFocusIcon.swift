import AppKit

let root = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .appendingPathComponent("GBPFlashFocus/Assets.xcassets")

func color(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1) -> NSColor {
    NSColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
}

func drawMark(size: CGFloat, includeBackground: Bool) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    let rect = NSRect(x: 0, y: 0, width: size, height: size)

    if includeBackground {
        let gradient = NSGradient(colors: [
            color(150, 205, 88),
            color(55, 142, 71),
            color(10, 73, 43)
        ])
        gradient?.draw(in: rect, angle: -70)

        color(213, 238, 152, 0.16).setStroke()
        for index in 0..<7 {
            let offset = CGFloat(index)
            let arc = NSBezierPath()
            arc.appendOval(in: NSRect(x: -size * 0.16 - offset * 28, y: size * 0.76 - offset * 22, width: size * 1.16 + offset * 54, height: size * 0.36 + offset * 28))
            arc.lineWidth = max(2, size / 120)
            arc.stroke()
        }
    }

    let center = CGPoint(x: size * 0.40, y: size * 0.58)
    let outer = size * 0.245
    let inner = size * 0.055
    let star = NSBezierPath()
    for index in 0..<10 {
        let angle = -CGFloat.pi / 2 + CGFloat(index) * CGFloat.pi / 5
        let radius = index.isMultiple(of: 2) ? outer : inner
        let point = CGPoint(x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius)
        index == 0 ? star.move(to: point) : star.line(to: point)
    }
    star.close()
    color(246, 211, 61).setFill()
    star.fill()

    color(255, 245, 123, 0.82).setStroke()
    for degrees in [-25.0, 50.0, 125.0] {
        let radians = degrees * .pi / 180
        let line = NSBezierPath()
        line.move(to: center)
        line.line(to: CGPoint(x: center.x + cos(radians) * size * 0.15, y: center.y + sin(radians) * size * 0.15))
        line.lineWidth = max(2, size / 38)
        line.stroke()
    }

    let titleFont = NSFont.systemFont(ofSize: size * 0.135, weight: .black)
    let subFont = NSFont.systemFont(ofSize: size * 0.052, weight: .medium)
    ("GBP" as NSString).draw(
        at: CGPoint(x: size * 0.56, y: size * 0.52),
        withAttributes: [.font: titleFont, .foregroundColor: color(247, 255, 242)]
    )
    ("FOCUS" as NSString).draw(
        at: CGPoint(x: size * 0.56, y: size * 0.42),
        withAttributes: [.font: subFont, .foregroundColor: color(203, 229, 167, 0.90)]
    )

    image.unlockFocus()
    return image
}

func savePNG(_ image: NSImage, to url: URL) throws {
    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let data = bitmap.representation(using: .png, properties: [:]) else {
        return
    }
    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try data.write(to: url)
}

try savePNG(drawMark(size: 1024, includeBackground: true), to: root.appendingPathComponent("AppIcon.appiconset/GBPFlashFocusIcon.png"))
try savePNG(drawMark(size: 256, includeBackground: false), to: root.appendingPathComponent("BrandLogo.imageset/BrandLogo.png"))
try savePNG(drawMark(size: 512, includeBackground: false), to: root.appendingPathComponent("BrandLogo.imageset/BrandLogo@2x.png"))
try savePNG(drawMark(size: 768, includeBackground: false), to: root.appendingPathComponent("BrandLogo.imageset/BrandLogo@3x.png"))

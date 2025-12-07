#!/usr/bin/env swift

// App Icon Generator for Troop 900 UI Showcase
// Run: swift GenerateAppIcon.swift
// This generates a 1024x1024 PNG app icon

import Foundation
import CoreGraphics
import CoreText
import ImageIO
import UniformTypeIdentifiers
import AppKit

let size: CGFloat = 1024
let colorSpace = CGColorSpaceCreateDeviceRGB()

// CalTrans Orange from the design system
let primaryOrange = CGColor(red: 1.0, green: 109.0/255.0, blue: 0.0, alpha: 1.0) // #FF6D00
let darkOrange = CGColor(red: 230.0/255.0, green: 81.0/255.0, blue: 0.0, alpha: 1.0) // #E65100
let white = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

func generateIcon(filename: String, backgroundColor: CGColor, textColor: CGColor) {
    guard let context = CGContext(
        data: nil,
        width: Int(size),
        height: Int(size),
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        print("Failed to create context")
        return
    }
    
    // Fill background
    context.setFillColor(backgroundColor)
    context.fill(CGRect(x: 0, y: 0, width: size, height: size))
    
    // Draw "T9" text
    context.setFillColor(textColor)
    
    // Draw "T9 UI" on a single line
    let font = CTFontCreateWithName("SF Pro Rounded" as CFString, 280, nil)
    let attributes: [CFString: Any] = [
        kCTFontAttributeName: font,
        kCTForegroundColorAttributeName: textColor
    ]
    let textString = CFAttributedStringCreate(nil, "T9 UI" as CFString, attributes as CFDictionary)!
    let line = CTLineCreateWithAttributedString(textString)
    let bounds = CTLineGetBoundsWithOptions(line, .useOpticalBounds)
    
    // Center text both horizontally and vertically
    let xOffset = (size - bounds.width) / 2 - bounds.origin.x
    let yOffset = (size - bounds.height) / 2 - bounds.origin.y
    
    context.textPosition = CGPoint(x: xOffset, y: yOffset)
    CTLineDraw(line, context)
    
    // Save image
    guard let image = context.makeImage() else {
        print("Failed to create image")
        return
    }
    
    let outputPath = "Troop900UIShowcase/Assets.xcassets/AppIcon.appiconset/\(filename)"
    let url = URL(fileURLWithPath: outputPath)
    
    guard let destination = CGImageDestinationCreateWithURL(
        url as CFURL,
        UTType.png.identifier as CFString,
        1,
        nil
    ) else {
        print("Failed to create destination for \(filename)")
        return
    }
    
    CGImageDestinationAddImage(destination, image, nil)
    
    if CGImageDestinationFinalize(destination) {
        print("✓ Generated \(filename)")
    } else {
        print("✗ Failed to save \(filename)")
    }
}

print("Generating Troop 900 UI Showcase App Icons...")
print("")

// Generate light mode icon (orange background, white text)
generateIcon(filename: "AppIcon.png", backgroundColor: primaryOrange, textColor: white)

// Generate dark mode icon (darker orange background, white text)
generateIcon(filename: "AppIcon-Dark.png", backgroundColor: darkOrange, textColor: white)

// Generate tinted icon (white background, orange elements) - for tinted appearance
let lightGray = CGColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
generateIcon(filename: "AppIcon-Tinted.png", backgroundColor: lightGray, textColor: primaryOrange)

print("")
print("Done! Update Contents.json to reference these files.")

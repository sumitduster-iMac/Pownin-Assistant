#!/usr/bin/env swift
/**
 * App Icon Generator for macOS
 * Generates all required icon sizes for macOS app bundles
 * 
 * Usage: swift generate_app_icons.swift [source-image] [output-directory]
 */

import Foundation
import AppKit

// MARK: - Icon Sizes Configuration
struct IconSize {
    let size: Int
    let scale: Int
    
    var filename: String {
        if scale == 1 {
            return "icon_\(size)x\(size).png"
        } else {
            return "icon_\(size)x\(size)@\(scale)x.png"
        }
    }
    
    var actualPixels: Int {
        return size * scale
    }
}

let macOSIconSizes: [IconSize] = [
    IconSize(size: 16, scale: 1),
    IconSize(size: 16, scale: 2),
    IconSize(size: 32, scale: 1),
    IconSize(size: 32, scale: 2),
    IconSize(size: 128, scale: 1),
    IconSize(size: 128, scale: 2),
    IconSize(size: 256, scale: 1),
    IconSize(size: 256, scale: 2),
    IconSize(size: 512, scale: 1),
    IconSize(size: 512, scale: 2)
]

// MARK: - Image Processing
func resizeImage(_ image: NSImage, to size: NSSize) -> NSImage {
    let newImage = NSImage(size: size)
    newImage.lockFocus()
    
    NSGraphicsContext.current?.imageInterpolation = .high
    
    image.draw(
        in: NSRect(origin: .zero, size: size),
        from: NSRect(origin: .zero, size: image.size),
        operation: .copy,
        fraction: 1.0
    )
    
    newImage.unlockFocus()
    return newImage
}

func saveAsPNG(_ image: NSImage, to url: URL) throws {
    guard let tiffData = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let pngData = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "IconGenerator", code: 1, userInfo: [
            NSLocalizedDescriptionKey: "Failed to convert image to PNG"
        ])
    }
    
    try pngData.write(to: url)
}

// MARK: - Main Function
func generateIcons(sourcePath: String, outputDirectory: String) {
    let fileManager = FileManager.default
    
    // Verify source exists
    guard fileManager.fileExists(atPath: sourcePath) else {
        print("Error: Source image not found at \(sourcePath)")
        exit(1)
    }
    
    // Load source image
    guard let sourceImage = NSImage(contentsOfFile: sourcePath) else {
        print("Error: Could not load source image")
        exit(1)
    }
    
    print("Source image: \(sourcePath)")
    print("Source size: \(Int(sourceImage.size.width))x\(Int(sourceImage.size.height))")
    print("Output directory: \(outputDirectory)")
    print("")
    
    // Create output directory if needed
    let outputURL = URL(fileURLWithPath: outputDirectory)
    do {
        try fileManager.createDirectory(at: outputURL, withIntermediateDirectories: true)
    } catch {
        print("Error creating output directory: \(error.localizedDescription)")
        exit(1)
    }
    
    // Generate each icon size
    var successCount = 0
    var failCount = 0
    
    for iconSize in macOSIconSizes {
        let targetSize = NSSize(
            width: CGFloat(iconSize.actualPixels),
            height: CGFloat(iconSize.actualPixels)
        )
        
        let resizedImage = resizeImage(sourceImage, to: targetSize)
        let outputPath = outputURL.appendingPathComponent(iconSize.filename)
        
        do {
            try saveAsPNG(resizedImage, to: outputPath)
            print("✓ Generated: \(iconSize.filename) (\(iconSize.actualPixels)x\(iconSize.actualPixels))")
            successCount += 1
        } catch {
            print("✗ Failed: \(iconSize.filename) - \(error.localizedDescription)")
            failCount += 1
        }
    }
    
    print("")
    print("Generation complete!")
    print("  Success: \(successCount)")
    print("  Failed: \(failCount)")
}

// MARK: - Entry Point
let args = CommandLine.arguments

if args.count < 2 {
    print("Usage: swift generate_app_icons.swift <source-image> [output-directory]")
    print("")
    print("Arguments:")
    print("  source-image      Path to source image (PNG, 1024x1024 recommended)")
    print("  output-directory  Path to output directory (default: ./AppIcon.appiconset)")
    print("")
    print("Example:")
    print("  swift generate_app_icons.swift icon-1024.png ./AppIcon.appiconset")
    exit(0)
}

let sourcePath = args[1]
let outputDirectory = args.count > 2 ? args[2] : "./AppIcon.appiconset"

generateIcons(sourcePath: sourcePath, outputDirectory: outputDirectory)

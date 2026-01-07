#!/usr/bin/env node
/**
 * Icon Generator for Pownin Assistant
 * Generates app icons for multiple platforms from an SVG source
 * 
 * Usage: node generate-icons.mjs [source-svg] [output-dir]
 */

import { execSync } from 'child_process';
import { existsSync, mkdirSync, writeFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));

// Icon sizes for different platforms
const ICON_SIZES = {
  mac: [16, 32, 64, 128, 256, 512, 1024],
  electron: [16, 24, 32, 48, 64, 96, 128, 256, 512],
  favicon: [16, 32, 48, 64, 128, 256]
};

function generateIcons(sourceSvg, outputDir) {
  const source = sourceSvg || join(__dirname, '../electron-app/assets/icon.svg');
  const output = outputDir || join(__dirname, '../generated-icons');

  if (!existsSync(source)) {
    console.error(`Source SVG not found: ${source}`);
    process.exit(1);
  }

  // Create output directories
  const dirs = ['mac', 'electron', 'favicon'];
  dirs.forEach(dir => {
    const path = join(output, dir);
    if (!existsSync(path)) {
      mkdirSync(path, { recursive: true });
    }
  });

  console.log('Generating icons from:', source);
  console.log('Output directory:', output);

  // Check for available tools
  const hasImageMagick = checkCommand('convert --version');
  const hasRsvg = checkCommand('rsvg-convert --version');

  if (!hasImageMagick && !hasRsvg) {
    console.log('\nNo image conversion tools found.');
    console.log('Install ImageMagick or librsvg to generate icons.');
    console.log('\nCreating placeholder script instead...');
    createPlaceholderScript(output);
    return;
  }

  const converter = hasRsvg ? 'rsvg' : 'imagemagick';
  console.log(`Using: ${converter}`);

  // Generate icons for each platform
  Object.entries(ICON_SIZES).forEach(([platform, sizes]) => {
    console.log(`\nGenerating ${platform} icons...`);
    sizes.forEach(size => {
      const outputFile = join(output, platform, `icon-${size}.png`);
      try {
        if (converter === 'rsvg') {
          execSync(`rsvg-convert -w ${size} -h ${size} "${source}" -o "${outputFile}"`);
        } else {
          execSync(`convert -background none -resize ${size}x${size} "${source}" "${outputFile}"`);
        }
        console.log(`  ✓ ${size}x${size}`);
      } catch (error) {
        console.log(`  ✗ ${size}x${size}: ${error.message}`);
      }
    });
  });

  console.log('\nIcon generation complete!');
}

function checkCommand(cmd) {
  try {
    execSync(cmd, { stdio: 'ignore' });
    return true;
  } catch {
    return false;
  }
}

function createPlaceholderScript(output) {
  const script = `#!/bin/bash
# Run this script on a system with ImageMagick or librsvg installed
# to generate the actual icons

SOURCE_SVG="../electron-app/assets/icon.svg"
SIZES=(16 32 64 128 256 512 1024)

for size in "\${SIZES[@]}"; do
  rsvg-convert -w \$size -h \$size "\$SOURCE_SVG" -o "icon-\$size.png"
done
`;
  writeFileSync(join(output, 'generate.sh'), script);
  console.log('Created placeholder script: generated-icons/generate.sh');
}

// Run if called directly
const args = process.argv.slice(2);
generateIcons(args[0], args[1]);

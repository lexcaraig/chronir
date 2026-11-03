import StyleDictionary from 'style-dictionary';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { registerChronirFormats } from './formats/chronir-formats.js';

// design-tokens/tokens/*.json is the single source of truth. This config generates the exact
// token files the apps compile; /sync-tokens copies build/ios/*.swift and build/android/*.kt
// into chronir/chronir/DesignSystem/Tokens/ and core/designsystem/.../designsystem/tokens/, and
// build/ios-widgets/WidgetTokens.swift into chronir/ChronirWidgets/Shared/ (kept in its own folder so the
// app's `cp build/ios/*.swift` never pulls the widget copy of `Color(hex:)` into the main target).

registerChronirFormats(StyleDictionary);

// Start from a clean output so stale files never get copied into the apps.
const here = path.dirname(fileURLToPath(import.meta.url));
for (const dir of ['build/ios', 'build/ios-widgets', 'build/android']) {
  fs.rmSync(path.join(here, dir), { recursive: true, force: true });
}

// Values stay raw (hex / numbers); the Chronir formats do all platform conversion.
const raw = { transforms: ['attribute/cti', 'name/camel'] };

const ios = [
  ['ColorTokens.swift', 'chronir/ios/colors', 'color'],
  ['TypographyTokens.swift', 'chronir/ios/typography', 'typography'],
  ['SpacingTokens.swift', 'chronir/ios/spacing', 'spacing'],
  ['RadiusTokens.swift', 'chronir/ios/radius', 'radius'],
  ['AnimationTokens.swift', 'chronir/ios/animation', 'animation'],
];

const android = [
  ['ColorTokens.kt', 'chronir/android/colors', 'color'],
  ['ColorSchemeTokens.kt', 'chronir/android/colorSchemes', 'color'],
  ['ExtendedColorTokens.kt', 'chronir/android/extendedColors', 'color'],
  ['TypographyTokens.kt', 'chronir/android/typography', 'typography'],
  ['SpacingTokens.kt', 'chronir/android/spacing', 'spacing'],
  ['RadiusTokens.kt', 'chronir/android/radius', 'radius'],
  ['AnimationTokens.kt', 'chronir/android/animation', 'animation'],
];

const files = (list) =>
  list.map(([destination, format, category]) => ({
    destination,
    format,
    filter: (token) => token.path[0] === category,
  }));

export default {
  source: ['tokens/**/*.json'],
  log: { verbosity: 'default' },
  platforms: {
    ios: { ...raw, buildPath: 'build/ios/', files: files(ios) },
    iosWidgets: {
      ...raw,
      buildPath: 'build/ios-widgets/',
      files: [
        {
          destination: 'WidgetTokens.swift',
          format: 'chronir/ios/widgets',
          filter: (token) => token.path[0] === 'color' || token.path[0] === 'spacing',
        },
      ],
    },
    android: { ...raw, buildPath: 'build/android/', files: files(android) },
  },
};

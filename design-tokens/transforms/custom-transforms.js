/**
 * Custom transforms for Chronir design tokens.
 *
 * These transforms can be registered with Style Dictionary to handle
 * platform-specific value conversions beyond the built-in transform groups.
 */

/**
 * Registers custom transforms on a StyleDictionary instance.
 * @param {import('style-dictionary').default} StyleDictionary
 */
export function registerCustomTransforms(StyleDictionary) {
  // Transform duration values to seconds for iOS (e.g. "300" -> "0.3")
  StyleDictionary.registerTransform({
    name: 'time/seconds',
    type: 'value',
    filter: (token) => token.type === 'duration' || token.$type === 'duration',
    transform: (token) => {
      const ms = parseFloat(token.value ?? token.$value);
      return `${ms / 1000}`;
    },
  });

  // Transform dimension values to CGFloat-friendly strings for iOS (append ".0")
  StyleDictionary.registerTransform({
    name: 'size/cgfloat',
    type: 'value',
    filter: (token) => token.type === 'dimension' || token.$type === 'dimension',
    transform: (token) => {
      const val = parseFloat(token.value ?? token.$value);
      return Number.isInteger(val) ? `${val}.0` : `${val}`;
    },
  });

  // Transform dimension values to dp for Android Compose
  StyleDictionary.registerTransform({
    name: 'size/compose/dp',
    type: 'value',
    filter: (token) => token.type === 'dimension' || token.$type === 'dimension',
    transform: (token) => {
      const val = parseFloat(token.value ?? token.$value);
      return `${val}`;
    },
  });

  // Transform duration values to milliseconds Long for Android Compose
  StyleDictionary.registerTransform({
    name: 'time/compose/ms',
    type: 'value',
    filter: (token) => token.type === 'duration' || token.$type === 'duration',
    transform: (token) => {
      return `${parseFloat(token.value ?? token.$value)}`;
    },
  });
}

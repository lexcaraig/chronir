import colorTokens from '@tokens/color.json'
import spacingTokens from '@tokens/spacing.json'
import radiusTokens from '@tokens/radius.json'
import typographyTokens from '@tokens/typography.json'
import animationTokens from '@tokens/animation.json'

// Build a flat lookup map from nested token objects
// e.g. { "color.primitive.blue.500": "#3B82F6" }
function buildLookup(obj, prefix = '') {
  const map = {}
  for (const [key, val] of Object.entries(obj)) {
    const path = prefix ? `${prefix}.${key}` : key
    if (val && typeof val === 'object' && 'value' in val) {
      map[path] = val.value
    } else if (val && typeof val === 'object') {
      Object.assign(map, buildLookup(val, path))
    }
  }
  return map
}

// Resolve references like "{color.primitive.blue.500}" to concrete values
function resolveReferences(lookup, maxDepth = 10) {
  const resolved = { ...lookup }
  const refPattern = /\{([^}]+)\}/

  for (let i = 0; i < maxDepth; i++) {
    let changed = false
    for (const [key, val] of Object.entries(resolved)) {
      if (typeof val === 'string') {
        const match = val.match(refPattern)
        if (match) {
          const refPath = match[1]
          if (resolved[refPath] !== undefined) {
            resolved[key] = val.replace(match[0], resolved[refPath])
            changed = true
          }
        }
      }
    }
    if (!changed) break
  }

  return resolved
}

// Flatten tokens into array of { path, value, description, category, group }
function flattenTokens(obj, category, prefix = '', group = '') {
  const tokens = []
  for (const [key, val] of Object.entries(obj)) {
    const path = prefix ? `${prefix}.${key}` : key
    if (val && typeof val === 'object' && 'value' in val) {
      tokens.push({
        path: `${category}.${path}`,
        name: key,
        rawValue: val.value,
        type: val.type || category,
        description: val.description || '',
        category,
        group: group || path.split('.')[0],
      })
    } else if (val && typeof val === 'object') {
      const nextGroup = group || key
      tokens.push(...flattenTokens(val, category, path, nextGroup))
    }
  }
  return tokens
}

// Build lookup from all sources
const allLookup = {
  ...buildLookup(colorTokens),
  ...buildLookup(spacingTokens),
  ...buildLookup(radiusTokens),
  ...buildLookup(typographyTokens),
  ...buildLookup(animationTokens),
}

const resolvedLookup = resolveReferences(allLookup)

// Flatten each category
const colorList = flattenTokens(colorTokens.color, 'color')
const spacingList = flattenTokens(spacingTokens.spacing, 'spacing')
const radiusList = flattenTokens(radiusTokens.radius, 'radius')
const animationList = flattenTokens(animationTokens.animation, 'animation')

// Typography is structured differently (nested properties, not single value)
function flattenTypography(obj, prefix = '', group = '') {
  const tokens = []
  for (const [key, val] of Object.entries(obj)) {
    const path = prefix ? `${prefix}.${key}` : key
    if (val && typeof val === 'object' && 'fontSize' in val) {
      tokens.push({
        path: `typography.${path}`,
        name: key,
        fontSize: val.fontSize.value,
        lineHeight: val.lineHeight.value,
        fontWeight: val.fontWeight.value,
        category: 'typography',
        group: group || path.split('.')[0],
      })
    } else if (val && typeof val === 'object') {
      tokens.push(...flattenTypography(val, path, group || key))
    }
  }
  return tokens
}

const typographyList = flattenTypography(typographyTokens.typography)

// Attach resolved values
for (const token of [...colorList, ...spacingList, ...radiusList, ...animationList]) {
  token.resolvedValue = resolvedLookup[token.path] ?? token.rawValue
}

// Group tokens by their group key
function groupBy(tokens, key = 'group') {
  const groups = {}
  for (const token of tokens) {
    const g = token[key]
    if (!groups[g]) groups[g] = []
    groups[g].push(token)
  }
  return groups
}

export const colors = {
  all: colorList,
  grouped: groupBy(colorList),
}

export const spacing = {
  all: spacingList,
  grouped: groupBy(spacingList),
}

export const radius = {
  all: radiusList,
}

export const typography = {
  all: typographyList,
  grouped: groupBy(typographyList),
}

export const animation = {
  all: animationList,
  grouped: groupBy(animationList),
}

// Extract theme-resolved token maps
function extractThemeTokens(lookup, prefix) {
  const theme = {}
  for (const [key, value] of Object.entries(lookup)) {
    if (key.startsWith(prefix + '.')) {
      const role = key.slice(prefix.length + 1)
      theme[role] = value
    }
  }
  return theme
}

export const lightTheme = extractThemeTokens(resolvedLookup, 'color.theme.light')
export const darkTheme = extractThemeTokens(resolvedLookup, 'color.theme.dark')

export { resolvedLookup }

// Convert a dot-separated token path to camelCase platform name
// e.g. "color.primitive.blue.500" → "colorPrimitiveBlue500"
function toCamelCase(path) {
  return path
    .split('.')
    .map((part, i) => {
      if (i === 0) return part
      return part.charAt(0).toUpperCase() + part.slice(1)
    })
    .join('')
}

export function swiftName(tokenPath) {
  const camel = toCamelCase(tokenPath)
  const category = tokenPath.split('.')[0]
  const prefix = {
    color: 'ChronirColors',
    spacing: 'ChronirSpacing',
    radius: 'ChronirRadius',
    typography: 'ChronirTypography',
    animation: 'ChronirAnimation',
  }[category] || 'Chronir'

  return `${prefix}.${camel}`
}

export function kotlinName(tokenPath) {
  const camel = toCamelCase(tokenPath)
  const category = tokenPath.split('.')[0]
  const prefix = {
    color: 'ChronirColors',
    spacing: 'ChronirSpacing',
    radius: 'ChronirRadius',
    typography: 'ChronirTypography',
    animation: 'ChronirAnimation',
  }[category] || 'Chronir'

  return `${prefix}.${camel}`
}

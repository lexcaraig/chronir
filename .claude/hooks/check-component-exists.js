// Hook: Component Existence Check
// Trigger: PreToolUse on Write for .tsx/.jsx files in marketing-videos
// Purpose: Check if component already exists in design-tokens before creating new ones
// Searches: design-tokens/docs/src/components/, design-tokens/tokens/

const fs = require('fs');
const path = require('path');

const DESIGN_TOKENS_ROOT = '/Users/lexcaraig/development/Chronir/design-tokens';
const COMPONENTS_DIR = path.join(DESIGN_TOKENS_ROOT, 'docs/src/components');
const TOKENS_DIR = path.join(DESIGN_TOKENS_ROOT, 'tokens');

let data = '';
process.stdin.on('data', chunk => data += chunk);
process.stdin.on('end', () => {
  const input = JSON.parse(data);
  const filePath = input.tool_input?.file_path || '';

  // Only check .tsx/.jsx files that look like components
  if (!/\.(tsx|jsx)$/.test(filePath)) {
    process.stdout.write(data);
    return;
  }

  // Only check files that look like new component creation
  const filename = path.basename(filePath, path.extname(filePath));
  const isComponent = /^[A-Z]/.test(filename) || /Component|Screen|Section|Preview|Mockup|Frame/.test(filename);
  if (!isComponent) {
    process.stdout.write(data);
    return;
  }

  // Extract component name from filename
  const componentName = filename;

  // Search design-tokens components for matches
  const matches = [];

  try {
    if (fs.existsSync(COMPONENTS_DIR)) {
      const componentFiles = fs.readdirSync(COMPONENTS_DIR).filter(f => /\.(jsx|tsx|js|ts)$/.test(f));

      for (const file of componentFiles) {
        const content = fs.readFileSync(path.join(COMPONENTS_DIR, file), 'utf8');

        // Check for exported component names
        const exportRegex = /export\s+(?:default\s+)?(?:function|const|class)\s+(\w+)/g;
        let match;
        while ((match = exportRegex.exec(content)) !== null) {
          const exportedName = match[1];
          if (isSimilar(componentName, exportedName)) {
            matches.push({ name: exportedName, file, type: 'component' });
          }
        }

        // Check for const component declarations
        const constRegex = /const\s+(\w+)\s*[:=]\s*(?:React\.FC|FC|\()/g;
        while ((match = constRegex.exec(content)) !== null) {
          const constName = match[1];
          if (isSimilar(componentName, constName)) {
            matches.push({ name: constName, file, type: 'component' });
          }
        }
      }
    }
  } catch (e) {
    // Silently continue if design-tokens aren't available
  }

  // Check token files for relevant token groups
  const tokenMatches = [];
  try {
    if (fs.existsSync(TOKENS_DIR)) {
      const tokenFiles = fs.readdirSync(TOKENS_DIR).filter(f => f.endsWith('.json'));
      const nameWords = splitWords(componentName).map(w => w.toLowerCase());

      for (const file of tokenFiles) {
        const tokenName = file.replace('.json', '');
        if (nameWords.some(w => tokenName.toLowerCase().includes(w))) {
          tokenMatches.push(file);
        }
      }
    }
  } catch (e) {}

  // Deduplicate matches
  const seen = new Set();
  const uniqueMatches = matches.filter(m => {
    const key = m.name + ':' + m.file;
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });

  if (uniqueMatches.length > 0 || tokenMatches.length > 0) {
    console.error('');
    console.error('[Hook] COMPONENT EXISTS CHECK');
    console.error('[Hook] ' + '='.repeat(55));
    console.error('[Hook] Creating: ' + componentName);
    console.error('[Hook]');

    if (uniqueMatches.length > 0) {
      console.error('[Hook] EXISTING COMPONENTS FOUND in design-tokens:');
      uniqueMatches.forEach(m => {
        console.error('[Hook]   - ' + m.name + ' in ' + m.file);
      });
      console.error('[Hook]');
      console.error('[Hook] BEFORE creating a new component:');
      console.error('[Hook]   1. Read the existing component from design-tokens/docs/src/components/' + uniqueMatches[0].file);
      console.error('[Hook]   2. Port/adapt it instead of building from scratch');
      console.error('[Hook]   3. Use the same token values and patterns');
    }

    if (tokenMatches.length > 0) {
      console.error('[Hook]');
      console.error('[Hook] RELEVANT TOKEN FILES:');
      tokenMatches.forEach(f => {
        console.error('[Hook]   - design-tokens/tokens/' + f);
      });
      console.error('[Hook]   Use these tokens for consistent styling');
    }

    console.error('[Hook] ' + '='.repeat(55));
    console.error('');
  }

  // Don't block — inform only
  process.stdout.write(data);
});

function splitWords(str) {
  return str.replace(/([a-z])([A-Z])/g, '$1 $2').split(/[\s_-]+/);
}

function isSimilar(target, candidate) {
  const targetWords = splitWords(target).map(w => w.toLowerCase());
  const candidateWords = splitWords(candidate).map(w => w.toLowerCase());

  // Exact match
  if (target.toLowerCase() === candidate.toLowerCase()) return true;

  // Significant word overlap (words > 2 chars)
  const significant = targetWords.filter(w => w.length > 2);
  const overlap = significant.filter(w => candidateWords.some(c => c.includes(w) || w.includes(c)));
  return overlap.length >= Math.ceil(significant.length * 0.5);
}

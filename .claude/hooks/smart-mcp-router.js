// Hook: Smart MCP/Tool Router
// Trigger: PreToolUse on WebSearch, Grep, Read
// Purpose: Suggest the best tool/MCP for the task based on context
// Routes: Context7 for library docs, Serena for symbol nav, design-tokens for components

let data = '';
process.stdin.on('data', chunk => data += chunk);
process.stdin.on('end', () => {
  const input = JSON.parse(data);
  const tool = input.tool || '';
  const toolInput = input.tool_input || {};

  // --- WebSearch routing ---
  if (tool === 'WebSearch') {
    const query = (toolInput.query || '').toLowerCase();

    // Remotion docs -> suggest Context7
    if (/remotion|video.*react|composition.*react|useCurrentFrame|interpolate|spring\(/.test(query)) {
      console.error('');
      console.error('[Hook] ROUTING: Remotion question detected');
      console.error('[Hook] Consider using Context7 MCP (resolve-library-id then query-docs)');
      console.error('[Hook] for up-to-date Remotion API docs instead of web search.');
      console.error('');
    }

    // Firebase/Supabase docs -> suggest MCP
    if (/firebase|firestore|cloud function|fcm/.test(query)) {
      console.error('');
      console.error('[Hook] ROUTING: Firebase question detected');
      console.error('[Hook] Use the Firebase MCP tools for project/config queries.');
      console.error('');
    }

    if (/supabase|edge function|rls|row level security/.test(query)) {
      console.error('');
      console.error('[Hook] ROUTING: Supabase question detected');
      console.error('[Hook] Use the Supabase MCP tools for project queries and SQL.');
      console.error('');
    }
  }

  // --- Read routing ---
  if (tool === 'Read') {
    const filePath = toolInput.file_path || '';

    // Reading a large Swift file -> suggest Serena for targeted symbol reads
    if (/\.swift$/.test(filePath)) {
      var isLargeishPath = /ViewModel|Service|Repository|Manager|Coordinator/.test(filePath);
      if (isLargeishPath) {
        console.error('[Hook] TIP: For targeted Swift symbol lookup, consider Serena find_symbol tool.');
      }
    }

    // Reading design-token source files -> remind about token pipeline
    if (/design-tokens\/tokens\//.test(filePath)) {
      console.error('[Hook] TIP: design-tokens are the source of truth. After modifying tokens,');
      console.error('[Hook] run: cd design-tokens && npm run build');
    }
  }

  // --- Grep routing ---
  if (tool === 'Grep') {
    var pattern = toolInput.pattern || '';
    var searchPath = toolInput.path || '';

    // Searching for Swift symbols across codebase -> suggest Serena
    if (/\.swift/.test(toolInput.glob || '') || /chronir\/chronir/.test(searchPath)) {
      if (/class |struct |protocol |func |enum /.test(pattern)) {
        console.error('[Hook] TIP: For Swift symbol navigation, Serena find_symbol or');
        console.error('[Hook] get_symbols_overview may be faster than Grep.');
      }
    }

    // Searching for component patterns -> remind about design-tokens
    if (/Component|Preview|Mockup|Screen.*Section/.test(pattern)) {
      console.error('[Hook] TIP: Component implementations live in design-tokens/docs/src/components/.');
      console.error('[Hook] Check there for existing renderers before creating new ones.');
    }
  }

  process.stdout.write(data);
});

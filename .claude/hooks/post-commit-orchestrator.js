// Hook: Post-Commit Orchestrator
// Trigger: PostToolUse on Bash
// Purpose: Detect git commits and build completions, suggest next workflow steps
// Orchestrates: /build-all after commits, error routing after failures

let data = '';
process.stdin.on('data', chunk => data += chunk);
process.stdin.on('end', () => {
  const input = JSON.parse(data);
  const command = input.tool_input?.command || '';
  const output = (input.tool_output?.stdout || input.tool_output?.output || '') +
    '\n' + (input.tool_output?.stderr || '');

  // Detect git commit
  if (/git commit/.test(command) && !input.error) {
    const hasCommit = /\[[\w/-]+\s+[a-f0-9]+\]/.test(output) || /create mode/.test(output);
    if (hasCommit) {
      // Check if commit message references a ticket ID
      const ticketMatch = output.match(/\[(TIER|LAUNCH|QA|FEAT|BUG|INFRA|ANDROID|PREMIUM)-\d+\]/i);
      console.error('');
      console.error('[Hook] COMMIT DETECTED');
      if (ticketMatch) {
        console.error(`[Hook] Ticket ${ticketMatch[0]} referenced. Move ticket from in-progress/ to untested/.`);
      } else {
        console.error('[Hook] No ticket ID in commit message. Ensure all work has a ticket (ticket-first workflow).');
      }
      console.error('[Hook] Consider running /build-all to verify all platforms build cleanly.');
      console.error('');
    }
  }

  // Detect npm/remotion build failure — suggest targeted fix
  if (/npm run (build|render)/.test(command) || /npx remotion/.test(command)) {
    const failed = /error/i.test(output) && (input.error || /failed|exit code [1-9]/i.test(output));
    if (failed) {
      if (/Cannot find module|Module not found/.test(output)) {
        console.error('');
        console.error('[Hook] BUILD FAILED: Missing module');
        console.error('[Hook] Run: npm install');
        console.error('');
      } else if (/Type error|TS\d+/.test(output)) {
        console.error('');
        console.error('[Hook] BUILD FAILED: TypeScript error');
        console.error('[Hook] Check types and imports in the failing file.');
        console.error('');
      } else if (/Could not find a composition/.test(output)) {
        console.error('');
        console.error('[Hook] BUILD FAILED: Composition not found');
        console.error('[Hook] Verify composition ID in Composition.tsx matches render command.');
        console.error('');
      }
    }
  }

  // Detect xcodebuild failure
  if (/xcodebuild/.test(command) && /BUILD FAILED|error:/.test(output)) {
    console.error('');
    console.error('[Hook] iOS BUILD FAILED');
    console.error('[Hook] Read the error output carefully. Common causes:');
    console.error('[Hook]   - Missing import');
    console.error('[Hook]   - Type mismatch');
    console.error('[Hook]   - Signing/entitlements (use CODE_SIGNING_ALLOWED=NO)');
    console.error('');
  }

  // Detect successful build — suggest next steps
  if (/npm run build/.test(command) && !input.error && !/error/i.test(output)) {
    const isClean = /compiled successfully|build succeeded/i.test(output) ||
      (!/error/i.test(output) && !/failed/i.test(output));
    if (isClean) {
      console.error('[Hook] Build succeeded. Ready for commit or render.');
    }
  }

  process.stdout.write(data);
});

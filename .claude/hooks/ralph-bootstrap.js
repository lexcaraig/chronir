// Hook: RALPH Loop Bootstrap
// Trigger: PreToolUse (fires once per session, similar to session-state-loader)
// Purpose: Detect RALPH loop iterations and restore task context
// State: /tmp/claude-ralph-state.json

const fs = require('fs');

const STATE_FILE = '/tmp/claude-ralph-state.json';
const LOADED_FLAG = '/tmp/claude-ralph-loaded';

let data = '';
process.stdin.on('data', chunk => data += chunk);
process.stdin.on('end', () => {
  // Only fire once per session
  if (fs.existsSync(LOADED_FLAG)) {
    process.stdout.write(data);
    return;
  }

  fs.writeFileSync(LOADED_FLAG, Date.now().toString());

  if (!fs.existsSync(STATE_FILE)) {
    process.stdout.write(data);
    return;
  }

  let state;
  try {
    state = JSON.parse(fs.readFileSync(STATE_FILE, 'utf8'));
  } catch (e) {
    process.stdout.write(data);
    return;
  }

  // Expire after 12 hours
  const hoursAgo = (Date.now() - new Date(state.savedAt).getTime()) / 3600000;
  if (hoursAgo > 12) {
    try { fs.unlinkSync(STATE_FILE); } catch (e) {}
    process.stdout.write(data);
    return;
  }

  const iteration = (state.iteration || 0) + 1;
  const timeLabel = hoursAgo < 1
    ? Math.round(hoursAgo * 60) + ' minutes ago'
    : Math.round(hoursAgo * 10) / 10 + ' hours ago';

  console.error('');
  console.error('[Hook] RALPH LOOP — Iteration #' + iteration + ' (state from ' + timeLabel + ')');
  console.error('[Hook] ' + '='.repeat(55));

  if (state.currentTask) {
    console.error('[Hook] CURRENT TASK: ' + state.currentTask);
  }

  if (state.completedSteps && state.completedSteps.length > 0) {
    console.error('[Hook] COMPLETED STEPS:');
    state.completedSteps.forEach(function(step, i) {
      console.error('[Hook]   ' + (i + 1) + '. ' + step);
    });
  }

  if (state.pendingSteps && state.pendingSteps.length > 0) {
    console.error('[Hook] REMAINING STEPS:');
    state.pendingSteps.forEach(function(step, i) {
      console.error('[Hook]   ' + (i + 1) + '. ' + step);
    });
  }

  if (state.blockers && state.blockers.length > 0) {
    console.error('[Hook] BLOCKERS:');
    state.blockers.forEach(function(b) {
      console.error('[Hook]   - ' + b);
    });
  }

  if (state.decisions && state.decisions.length > 0) {
    console.error('[Hook] KEY DECISIONS MADE:');
    state.decisions.forEach(function(d) {
      console.error('[Hook]   - ' + d);
    });
  }

  if (state.filesModified && state.filesModified.length > 0) {
    console.error('[Hook] FILES MODIFIED THIS LOOP:');
    state.filesModified.slice(0, 10).forEach(function(f) {
      console.error('[Hook]   - ' + f);
    });
  }

  console.error('[Hook] ' + '='.repeat(55));
  console.error('[Hook] Resume from where you left off. Do NOT repeat completed steps.');
  console.error('');

  // Update iteration count for next loop
  state.iteration = iteration;
  state.savedAt = new Date().toISOString();
  try {
    fs.writeFileSync(STATE_FILE, JSON.stringify(state, null, 2));
  } catch (e) {}

  process.stdout.write(data);
});

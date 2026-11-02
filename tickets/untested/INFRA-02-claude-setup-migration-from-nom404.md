# INFRA-02: Adapt the Nom404 `.claude/` setup to Chronir

**Status:** Untested
**Platform:** Tooling

## Goal
Reuse the Nom404 Claude Code setup (agents, commands, skills, hooks, rules, workflows, routines) in Chronir with every reference pointing at this project: SwiftUI/AlarmKit, Compose/AlarmManager, Firebase rules, design tokens, tickets/ lifecycle, xcodebuild/gradlew gates, asc App Store Connect flow.

## Done
- Deleted all Nom404-only pieces (web, Flutter, Cloud Functions, payments, SEO, wiki, blog, Vercel, Playwright, turbo).
- Restored and merged Chronir's original agents/commands/skills from git history.
- 29 hooks rewired in `.claude/settings.json`; `settings.local.json` reset to a Chronir allow list.
- Rules registry rewritten (+ `alarm-engine.md`, `android.md`, `firebase.md`); workflows retargeted; `ARCHITECTURE.md` rewritten.
- CLAUDE.md command/agent tables regenerated from frontmatter.
- `chronir/ExportOptions.plist` added for the asc upload flow.
- Plan: `tasks/plan-claude-setup-migration.md`.

## Verification
- [x] `node --check` on every hook and workflow
- [x] settings JSON valid; no `nom404|flutter|playwright|turbo|vercel|supabase` references outside the generic third-party skills
- [x] every agent/hook/command referenced by commands, rules, workflows, and CLAUDE.md exists
- [ ] Run `/status`, `/implement-task` on a real ticket, and one `git commit` through the gate chain in a fresh session

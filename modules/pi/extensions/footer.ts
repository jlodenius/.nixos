import { homedir } from "node:os";
import { isAbsolute, relative, sep } from "node:path";
import { stripVTControlCharacters } from "node:util";
import type {
  ExtensionAPI,
  ExtensionContext,
  SessionEntry,
} from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

function formatTokens(count: number): string {
  if (count < 1000) return count.toString();
  if (count < 10000) return `${(count / 1000).toFixed(1)}k`;
  if (count < 1000000) return `${Math.round(count / 1000)}k`;
  if (count < 10000000) return `${(count / 1000000).toFixed(1)}M`;
  return `${Math.round(count / 1000000)}M`;
}

function singleLine(text: string): string {
  return stripVTControlCharacters(text).replace(/[\x00-\x1f\x7f-\x9f]/g, " ");
}

function formatDirectory(cwd: string): string {
  const path = relative(homedir(), cwd);
  if (path === "") return "~";
  if (path === ".." || path.startsWith(`..${sep}`) || isAbsolute(path))
    return cwd;
  return `~${sep}${path}`;
}

function sessionCost(entries: readonly SessionEntry[]): number {
  let cost = 0;
  for (const entry of entries) {
    if (
      entry.type === "message" &&
      (entry.message.role === "assistant" ||
        entry.message.role === "toolResult")
    ) {
      cost += entry.message.usage?.cost.total ?? 0;
    } else if (entry.type === "compaction" || entry.type === "branch_summary") {
      cost += entry.usage?.cost.total ?? 0;
    }
  }
  return cost;
}

function usingSubscription(ctx: ExtensionContext): boolean {
  const model = ctx.model;
  if (!model) return false;
  if (model.provider === "kimi-coding") return true;
  return (
    ctx.modelRegistry.isUsingOAuth(model) &&
    ctx.modelRegistry.getProvider(model.provider)?.auth.oauth
      ?.isSubscription === true
  );
}

export default function(pi: ExtensionAPI) {
  let dispose: (() => void) | undefined;

  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui") return;

    ctx.ui.setFooter((tui, theme, footerData) => {
      let unsubscribe: (() => void) | undefined = footerData.onBranchChange(
        () => tui.requestRender(),
      );
      const cleanup = () => {
        unsubscribe?.();
        unsubscribe = undefined;
      };
      dispose = cleanup;

      return {
        dispose: cleanup,
        invalidate() { },
        render(width: number): string[] {
          const branch = footerData.getGitBranch();
          const directory = formatDirectory(ctx.cwd);
          const location = singleLine(
            `${directory}${branch ? ` (${branch})` : ""}`,
          );

          const usage = ctx.getContextUsage();
          const used =
            usage?.tokens === null ? "?" : formatTokens(usage?.tokens ?? 0);
          const total = formatTokens(
            usage?.contextWindow ?? ctx.model?.contextWindow ?? 0,
          );
          const context = theme.fg(
            (usage?.percent ?? 0) > 90 ? "error" : "warning",
            `${used}/${total}`,
          );
          const cost = sessionCost(ctx.sessionManager.getEntries()).toFixed(3);
          const subscription = usingSubscription(ctx) ? " (sub)" : "";
          const left = truncateToWidth(
            theme.fg("warning", `$${cost}${subscription} `) + context,
            width,
            "",
          );

          const model = ctx.model;
          const level = ctx.thinkingLevel ?? "off";
          const thinking = model?.reasoning
            ? ` • ${level === "off" ? "thinking off" : level}`
            : "";
          const label = model
            ? `(${model.provider}) ${model.id}${thinking}`
            : "no-model";
          const available = Math.max(0, width - visibleWidth(left) - 2);
          const right = truncateToWidth(
            theme.fg("warning", singleLine(label)),
            available,
            "",
          );
          const padding = " ".repeat(
            Math.max(0, width - visibleWidth(left) - visibleWidth(right)),
          );

          return [
            truncateToWidth(theme.fg("dim", location), width, ""),
            left + padding + right,
          ];
        },
      };
    });
  });

  pi.on("session_shutdown", () => {
    dispose?.();
    dispose = undefined;
  });
}

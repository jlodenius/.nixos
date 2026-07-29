import {
	DynamicBorder,
	type ExtensionAPI,
	type ExtensionCommandContext,
	getMarkdownTheme,
} from "@earendil-works/pi-coding-agent";
import { Container, Markdown, matchesKey, Text } from "@earendil-works/pi-tui";

interface UsageWindow {
	used_percent?: number;
	limit_window_seconds?: number;
	reset_after_seconds?: number;
	reset_at?: number;
}

interface RateLimit {
	primary_window?: UsageWindow | null;
	secondary_window?: UsageWindow | null;
}

interface UsageResponse {
	plan_type?: string;
	rate_limit?: RateLimit | null;
	additional_rate_limits?: Array<{
		limit_name?: string;
		metered_feature?: string;
		rate_limit?: RateLimit | null;
	}> | null;
	credits?: {
		has_credits?: boolean;
		unlimited?: boolean;
		balance?: string;
	} | null;
	spend_control?: {
		reached?: boolean;
		individual_limit?: {
			used_percent?: number;
			remaining?: string;
			reset_at?: number;
		} | null;
	} | null;
	rate_limit_reset_credits?: {
		available_count?: number;
		applicable_available_count?: number;
	} | null;
}

function accountIdFromToken(token: string): string | undefined {
	try {
		const payload = JSON.parse(
			Buffer.from(token.split(".")[1] ?? "", "base64url").toString("utf8"),
		);
		const accountId =
			payload?.["https://api.openai.com/auth"]?.chatgpt_account_id;
		return typeof accountId === "string" && accountId ? accountId : undefined;
	} catch {
		return undefined;
	}
}

function windowName(seconds?: number): string {
	if (!seconds) return "usage";
	const known: Array<[number, string]> = [
		[5 * 60 * 60, "5h"],
		[24 * 60 * 60, "daily"],
		[7 * 24 * 60 * 60, "weekly"],
		[30 * 24 * 60 * 60, "monthly"],
	];
	const match = known.find(
		([duration]) => Math.abs(seconds - duration) <= duration * 0.05,
	);
	return match?.[1] ?? `${Math.round(seconds / 3600)}h`;
}

function relativeTime(seconds?: number): string {
	if (seconds === undefined) return "unknown";
	const days = Math.floor(seconds / 86400);
	const hours = Math.floor((seconds % 86400) / 3600);
	const minutes = Math.floor((seconds % 3600) / 60);
	return (
		[
			days && `${days}d`,
			hours && `${hours}h`,
			!days && minutes && `${minutes}m`,
		]
			.filter(Boolean)
			.join(" ") || "now"
	);
}

function formatWindow(label: string, window: UsageWindow): string {
	const used = window.used_percent ?? 0;
	const reset = window.reset_at
		? new Date(window.reset_at * 1000).toLocaleString()
		: "unknown";
	return `- **${label} · ${windowName(window.limit_window_seconds)}:** ${used}% used, ${Math.max(0, 100 - used)}% left · resets ${reset} (${relativeTime(window.reset_after_seconds)})`;
}

function formatUsage(data: UsageResponse): string {
	const lines = [
		"# OpenAI Usage",
		"",
		`Plan: **${data.plan_type ?? "unknown"}**`,
		"",
	];
	const appendLimit = (label: string, limit?: RateLimit | null) => {
		if (limit?.primary_window)
			lines.push(formatWindow(label, limit.primary_window));
		if (limit?.secondary_window)
			lines.push(formatWindow(label, limit.secondary_window));
	};

	appendLimit("Codex", data.rate_limit);
	for (const extra of data.additional_rate_limits ?? []) {
		appendLimit(
			extra.limit_name ?? extra.metered_feature ?? "Additional",
			extra.rate_limit,
		);
	}

	if (!lines.some((line) => line.startsWith("- **")))
		lines.push("No active limits reported.");

	const credits = data.credits;
	if (credits?.unlimited) lines.push("", "Credits: **unlimited**");
	else if (credits?.has_credits)
		lines.push("", `Credits: **${credits.balance ?? "available"}**`);

	const resetCredits =
		data.rate_limit_reset_credits?.applicable_available_count ??
		data.rate_limit_reset_credits?.available_count;
	if (resetCredits !== undefined)
		lines.push(`Reset credits: **${resetCredits}**`);

	const individual = data.spend_control?.individual_limit;
	if (individual) {
		lines.push(
			`Spend control: **${individual.used_percent ?? 0}% used**, ${individual.remaining ?? "unknown"} remaining`,
		);
	}

	return lines.join("\n");
}

async function showUsage(
	markdown: string,
	ctx: ExtensionCommandContext,
): Promise<void> {
	if (ctx.mode !== "tui") {
		ctx.ui.notify(markdown, "info");
		return;
	}

	await ctx.ui.custom((_tui, theme, _keybindings, done) => {
		const container = new Container();
		const border = new DynamicBorder((text: string) =>
			theme.fg("accent", text),
		);
		container.addChild(border);
		container.addChild(new Markdown(markdown, 1, 1, getMarkdownTheme()));
		container.addChild(
			new Text(theme.fg("dim", "Press Enter or Esc to close"), 1, 0),
		);
		container.addChild(border);

		return {
			render: (width: number) => container.render(width),
			invalidate: () => container.invalidate(),
			handleInput: (input: string) => {
				if (matchesKey(input, "enter") || matchesKey(input, "escape"))
					done(undefined);
			},
		};
	});
}

export default function (pi: ExtensionAPI) {
	pi.registerCommand("usage", {
		description: "Show OpenAI Codex usage limits",
		handler: async (_args, ctx) => {
			try {
				const resolved =
					await ctx.modelRegistry.getProviderAuth("openai-codex");
				const token = resolved?.auth.apiKey;
				const accountId = token && accountIdFromToken(token);
				if (!token || !accountId) {
					ctx.ui.notify("OpenAI Codex login required", "warning");
					return;
				}

				const headers = new Headers();
				for (const [name, value] of Object.entries(
					resolved.auth.headers ?? {},
				)) {
					if (typeof value === "string") headers.set(name, value);
				}
				headers.set("authorization", `Bearer ${token}`);
				headers.set("chatgpt-account-id", accountId);

				const response = await fetch(
					"https://chatgpt.com/backend-api/wham/usage",
					{
						headers,
						signal: AbortSignal.timeout(15_000),
					},
				);
				if (!response.ok)
					throw new Error(`OpenAI returned HTTP ${response.status}`);
				await showUsage(
					formatUsage((await response.json()) as UsageResponse),
					ctx,
				);
			} catch (error) {
				ctx.ui.notify(
					error instanceof Error ? error.message : String(error),
					"error",
				);
			}
		},
	});
}

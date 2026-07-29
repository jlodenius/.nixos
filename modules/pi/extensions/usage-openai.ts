import {
	DynamicBorder,
	type ExtensionAPI,
	type ExtensionCommandContext,
	getMarkdownTheme,
} from "@earendil-works/pi-coding-agent";
import { Key, Markdown, matchesKey, Text } from "@earendil-works/pi-tui";

interface UsageWindow {
	used_percent?: number;
	limit_window_seconds?: number;
	reset_after_seconds?: number;
	reset_at?: number;
}

interface RateLimit {
	allowed?: boolean;
	limit_reached?: boolean;
	primary_window?: UsageWindow | null;
	secondary_window?: UsageWindow | null;
}

interface UsageResponse {
	plan_type?: string;
	rate_limit?: RateLimit | null;
	code_review_rate_limit?: RateLimit | null;
	code_review_rate_limits?: RateLimit | null;
	additional_rate_limits?: Array<{
		limit_name?: string;
		metered_feature?: string;
		rate_limit?: RateLimit | null;
	}> | null;
	rate_limit_reached_type?: string | { type?: string; kind?: string } | null;
	rate_limit_reset_credits?: {
		available_count?: number;
		applicable_available_count?: number;
	} | null;
	promo?:
		| string
		| {
				title?: string;
				message?: string;
				description?: string;
		  }
		| null;
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

function stripControlCharacters(value: string): string {
	return Array.from(value, (character) => {
		const code = character.charCodeAt(0);
		return code <= 31 || code === 127 ? " " : character;
	}).join("");
}

function displayText(value: string): string {
	return stripControlCharacters(value)
		.replace(/([\\`*_[\]<>])/g, "\\$1")
		.trim();
}

function labelText(value: string): string {
	if (value === "prolite") return "Pro Lite";
	return value
		.replace(/[_-]+/g, " ")
		.replace(/\b\w/g, (character) => character.toUpperCase());
}

function codeText(value: string): string {
	return stripControlCharacters(value).replace(/`/g, "\\`").trim();
}

function formatDuration(seconds?: number): string {
	if (seconds === undefined || !Number.isFinite(seconds)) return "unknown";
	if (seconds <= 0) return "now";
	const units: Array<[number, string]> = [
		[604800, "w"],
		[86400, "d"],
		[3600, "h"],
		[60, "m"],
		[1, "s"],
	];
	let remaining = Math.round(seconds);
	const parts: string[] = [];
	for (const [size, suffix] of units) {
		const amount = Math.floor(remaining / size);
		if (amount > 0) {
			parts.push(`${amount}${suffix}`);
			remaining %= size;
		}
		if (parts.length === 2) break;
	}
	return parts.join(" ") || "now";
}

function windowName(seconds?: number): string {
	if (seconds === undefined) return "Usage window";
	const known = new Map([
		[18000, "5-hour"],
		[86400, "Daily"],
		[604800, "Weekly"],
		[2592000, "Monthly"],
	]);
	return known.get(seconds) ?? `${formatDuration(seconds)} window`;
}

function formatReset(epochSeconds?: number, afterSeconds?: number): string {
	const details: string[] = [];
	if (epochSeconds !== undefined) {
		const date = new Date(epochSeconds * 1000);
		if (!Number.isNaN(date.getTime())) details.push(date.toLocaleString());
	}
	if (afterSeconds !== undefined)
		details.push(`${formatDuration(afterSeconds)} from this snapshot`);
	return details.length > 0 ? details.join(" · ") : "Not reported";
}

function clampPercent(value: number): number {
	return Math.min(100, Math.max(0, value));
}

function progressBar(percentUsed: number): string {
	const segments = 20;
	const filled = Math.round((clampPercent(percentUsed) / 100) * segments);
	return `\`${"█".repeat(filled)}${"░".repeat(segments - filled)}\``;
}

function formatWindow(position: string, window: UsageWindow): string[] {
	const lines = [
		`**${windowName(window.limit_window_seconds)} · ${position}**`,
	];
	if (window.used_percent !== undefined) {
		const used = clampPercent(window.used_percent);
		const remaining = 100 - used;
		lines.push(`${progressBar(used)} **${used}% used** · ${remaining}% left`);
	} else {
		lines.push("Usage percentage not reported");
	}
	lines.push(
		`Window length: **${formatDuration(window.limit_window_seconds)}**`,
		`Reset: **${formatReset(window.reset_at, window.reset_after_seconds)}**`,
		"",
	);
	return lines;
}

function statusText(limit: RateLimit): string {
	const values: string[] = [];
	if (limit.allowed !== undefined)
		values.push(limit.allowed ? "Allowed" : "Blocked");
	if (limit.limit_reached !== undefined)
		values.push(limit.limit_reached ? "Limit reached" : "Limit not reached");
	return values.join(" · ") || "Status not reported";
}

function appendLimit(
	lines: string[],
	title: string,
	limit: RateLimit,
	requirement?: string,
): void {
	lines.push(
		`## ${displayText(title)}`,
		"",
		`Status: **${statusText(limit)}**`,
	);
	if (requirement) lines.push("", requirement);
	lines.push("");
	let windows = 0;
	if (limit.primary_window) {
		lines.push(...formatWindow("primary window", limit.primary_window));
		windows++;
	}
	if (limit.secondary_window) {
		lines.push(...formatWindow("secondary window", limit.secondary_window));
		windows++;
	}
	if (windows === 0) lines.push("No usage windows reported.", "");
}

function formatUsage(data: UsageResponse): string {
	const plan = data.plan_type
		? displayText(labelText(data.plan_type))
		: "Unknown";
	const lines = ["# OpenAI Codex Usage", "", `Plan: **${plan}**`, ""];

	if (data.rate_limit)
		appendLimit(lines, "Codex · default model pool", data.rate_limit);
	const codeReviewLimit =
		data.code_review_rate_limit ?? data.code_review_rate_limits;
	if (codeReviewLimit) appendLimit(lines, "Code review", codeReviewLimit);
	for (const extra of data.additional_rate_limits ?? []) {
		if (!extra.rate_limit) continue;
		const name =
			extra.limit_name ?? extra.metered_feature ?? "Additional model";
		const feature = extra.metered_feature
			? ` Backend meter: \`${codeText(extra.metered_feature)}\`.`
			: "";
		appendLimit(
			lines,
			`${name} · model-specific pool`,
			extra.rate_limit,
			`**Model requirement:** this separate limit applies only to usage metered as **${displayText(name)}**.${feature} Other Codex models use the default pool above.`,
		);
	}
	if (
		!data.rate_limit &&
		!codeReviewLimit &&
		!data.additional_rate_limits?.length
	)
		lines.push("No rate limits reported.", "");

	if (data.rate_limit_reached_type) {
		const reached =
			typeof data.rate_limit_reached_type === "string"
				? data.rate_limit_reached_type
				: (data.rate_limit_reached_type.type ??
					data.rate_limit_reached_type.kind ??
					"unknown");
		lines.push(
			"## Account restriction",
			"",
			`Reason: **${displayText(labelText(reached))}**`,
			"",
		);
	}

	if (data.rate_limit_reset_credits) {
		const resets = data.rate_limit_reset_credits;
		lines.push("## Usage limit resets", "");
		if (resets.available_count !== undefined)
			lines.push(`- Available: **${resets.available_count}**`);
		if (resets.applicable_available_count !== undefined)
			lines.push(`- Applicable now: **${resets.applicable_available_count}**`);
		lines.push("");
	}

	if (data.promo) {
		const promo =
			typeof data.promo === "string"
				? data.promo
				: [data.promo.title, data.promo.message, data.promo.description]
						.filter((value): value is string => Boolean(value))
						.join(" — ");
		if (promo) lines.push("## Offer", "", displayText(promo), "");
	}

	return lines.join("\n").trimEnd();
}

async function showUsage(
	markdown: string,
	ctx: ExtensionCommandContext,
): Promise<void> {
	if (ctx.mode !== "tui") {
		ctx.ui.notify(markdown, "info");
		return;
	}

	await ctx.ui.custom((tui, theme, _keybindings, done) => {
		const border = new DynamicBorder((text: string) =>
			theme.fg("accent", text),
		);
		const content = new Markdown(markdown, 1, 0, getMarkdownTheme());
		const footer = new Text("", 1, 0);
		let scrollOffset = 0;
		let pageSize = 1;
		let maxOffset = 0;

		return {
			render: (width: number) => {
				const contentLines = content.render(width);
				pageSize = Math.max(4, tui.terminal.rows - 4);
				maxOffset = Math.max(0, contentLines.length - pageSize);
				scrollOffset = Math.min(scrollOffset, maxOffset);
				const position =
					maxOffset > 0
						? ` · ${scrollOffset + 1}–${Math.min(scrollOffset + pageSize, contentLines.length)} of ${contentLines.length}`
						: "";
				footer.setText(
					theme.fg("dim", `↑↓/PgUp/PgDn scroll${position} · Enter/Esc close`),
				);
				return [
					...border.render(width),
					...contentLines.slice(scrollOffset, scrollOffset + pageSize),
					...footer.render(width),
					...border.render(width),
				];
			},
			invalidate: () => {
				border.invalidate();
				content.invalidate();
				footer.invalidate();
			},
			handleInput: (input: string) => {
				if (matchesKey(input, Key.enter) || matchesKey(input, Key.escape)) {
					done(undefined);
					return;
				}
				if (matchesKey(input, Key.up)) scrollOffset--;
				else if (matchesKey(input, Key.down)) scrollOffset++;
				else if (matchesKey(input, Key.pageUp)) scrollOffset -= pageSize;
				else if (matchesKey(input, Key.pageDown)) scrollOffset += pageSize;
				else if (matchesKey(input, Key.home)) scrollOffset = 0;
				else if (matchesKey(input, Key.end)) scrollOffset = maxOffset;
				scrollOffset = Math.min(maxOffset, Math.max(0, scrollOffset));
				tui.requestRender();
			},
		};
	});
}

export default function (pi: ExtensionAPI) {
	pi.registerCommand("usage-openai", {
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

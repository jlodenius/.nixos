import { mkdtemp, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type {
	ExtensionAPI,
	ExtensionContext,
	SessionEntry,
} from "@earendil-works/pi-coding-agent";

function lastResponse(entries: SessionEntry[]): string | undefined {
	for (let index = entries.length - 1; index >= 0; index--) {
		const entry = entries[index];
		if (
			entry.type !== "message" ||
			entry.message?.role !== "assistant" ||
			!Array.isArray(entry.message.content)
		)
			continue;
		const text = entry.message.content
			.filter((part: unknown): part is { type: "text"; text: string } => {
				return (
					typeof part === "object" &&
					part !== null &&
					(part as { type?: string }).type === "text" &&
					typeof (part as { text?: unknown }).text === "string"
				);
			})
			.map((part: { text: string }) => part.text)
			.join("\n")
			.trim();
		if (text) return text;
	}
	return undefined;
}

async function openLastResponse(pi: ExtensionAPI, ctx: ExtensionContext) {
	if (!process.env.TMUX) {
		ctx.ui.notify("Pi is not running inside tmux", "warning");
		return;
	}

	const response = lastResponse(ctx.sessionManager.getBranch());
	if (!response) {
		ctx.ui.notify("No assistant response found", "warning");
		return;
	}

	const directory = await mkdtemp(join(tmpdir(), "pi-last-response-"));
	const file = join(directory, "response.md");
	await writeFile(file, `${response}\n`, { mode: 0o600 });

	const command = `trap 'rm -rf -- "${directory}"' EXIT HUP TERM; nvim -R -- '${file}'`;
	const result = await pi.exec("tmux", [
		"new-window",
		"-n",
		"pi-response",
		command,
	]);
	if (result.code !== 0) {
		await rm(directory, { recursive: true, force: true });
		ctx.ui.notify(
			result.stderr.trim() || "Failed to open tmux window",
			"error",
		);
	}
}

export default function (pi: ExtensionAPI) {
	pi.registerCommand("last", {
		description: "Open the last response in Neovim in a new tmux window",
		handler: async (_args, ctx) => openLastResponse(pi, ctx),
	});

	pi.registerShortcut("ctrl+l", {
		description: "Open the last response in Neovim",
		handler: async (ctx) => openLastResponse(pi, ctx),
	});
}

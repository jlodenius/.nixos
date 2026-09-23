import { SettingsManager, type ExtensionAPI } from "@earendil-works/pi-coding-agent";

const handoffKey = Symbol.for("nixos.pi.session-model.handoffs");
const processState = globalThis as typeof globalThis & {
	[handoffKey]?: Map<string | undefined, { provider: string; id: string }>;
};
// /new reloads extension modules, so the handoff must outlive the old instance.
const handoffs = processState[handoffKey] ??= new Map();

export default function (pi: ExtensionAPI) {
	let original: typeof SettingsManager.prototype.setDefaultModelAndProvider | undefined;
	const keepDefaults = () => {};

	pi.on("session_start", async (event, ctx) => {
		if (!original) {
			original = SettingsManager.prototype.setDefaultModelAndProvider;
			SettingsManager.prototype.setDefaultModelAndProvider = keepDefaults;
		}
		if (event.reason !== "new") return;

		const sessionFile = ctx.sessionManager.getSessionFile();
		const selected = handoffs.get(sessionFile);
		handoffs.delete(sessionFile);
		if (!selected) return;
		if (ctx.model?.provider === selected.provider && ctx.model.id === selected.id) return;

		const model = ctx.modelRegistry.find(selected.provider, selected.id);
		if (!model || !(await pi.setModel(model))) {
			ctx.ui.notify(`Could not keep model ${selected.provider}/${selected.id}`, "warning");
		}
	});

	pi.on("session_shutdown", (event, ctx) => {
		if (event.reason === "new" && ctx.model) {
			handoffs.set(event.targetSessionFile, { provider: ctx.model.provider, id: ctx.model.id });
		}
		if (original && SettingsManager.prototype.setDefaultModelAndProvider === keepDefaults) {
			SettingsManager.prototype.setDefaultModelAndProvider = original;
		}
		original = undefined;
	});
}

import { SettingsManager, type ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	let original: typeof SettingsManager.prototype.setDefaultModelAndProvider | undefined;
	const keepDefaults = () => {};

	pi.on("session_start", () => {
		if (original) return;
		original = SettingsManager.prototype.setDefaultModelAndProvider;
		// Pi's picker and session API both persist defaults, with no opt-out hook.
		SettingsManager.prototype.setDefaultModelAndProvider = keepDefaults;
	});

	pi.on("session_shutdown", () => {
		if (original && SettingsManager.prototype.setDefaultModelAndProvider === keepDefaults) {
			SettingsManager.prototype.setDefaultModelAndProvider = original;
		}
		original = undefined;
	});
}

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { loadVoiceBuild } from "/home/jacob/Development/paj-voice/src/build-loader.js";

export default async function (pi: ExtensionAPI) {
	const { root, registerVoice } = await loadVoiceBuild(
		"/home/jacob/Development/paj-voice/result-addon",
	);
	registerVoice(pi, Type, {
		buildId: root,
		env: {
			...process.env,
			PAJ_VOICE_CONFIG: "/home/jacob/.nixos/modules/pi/paj/paj.json",
		},
	});
}

import { Controller } from "@hotwired/stimulus";
export default class extends Controller {
	static targets = ["video"];

	async startCamera() {
		try {
			const stream = await navigator.mediaDevices.getUserMedia({
				audio: false,
				video: true,
			});
			this.videoTarget.srcObject = stream;
			await this.videoTarget.play();
		} catch (e) {
			console.warn("Camera not available", e.message);
		}
	}

	stopCamera() {
		const stream = this.videoTarget.srcObject;
		if (!stream) return;

		stream.getTracks().forEach((track) => {
			track.stop();
		});
		this.videoTarget.srcObject = null;
	}
}

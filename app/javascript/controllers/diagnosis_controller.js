import { Controller } from "@hotwired/stimulus";
export default class extends Controller {
	static targets = [
		"interviewVideo",
		"overlay",
		"canvas",
		"message",
		"preview",
		"feedback",
		"startButton",
		"resultButton",
		"backToHomeButton",
		"loader",
		"aiDiagnosis",
	];
	static values = {
		prepDuration: { type: Number, default: 15000 },
		intervalDuration: { type: Number, default: 10000 },
		totalShots: { type: Number, default: 2 },
	};

	async startCamera() {
		try {
			const stream = await navigator.mediaDevices.getUserMedia({
				audio: false,
				video: true,
			});
			this.previewTarget.srcObject = stream;
			await this.previewTarget.play();
		} catch (e) {
			console.error("Camera not available", e);
			this.teardown();
		}
	}

	async start() {
		this.overlayTarget.classList.add("hidden");
		this.messageTarget.textContent = "診断中...";
		this.startButtonTarget.disabled = true;
		try {
			await this.interviewVideoTarget.play();
		} catch (e) {
			console.error("Interview video not available", e);
			this.teardown();
		}
		this.prepTimer = setTimeout(() => {
			this.startIntervalCapture();
		}, this.prepDurationValue);

		this.capturedPhotos = [];
		this.interviewVideoTarget.addEventListener("ended", () => {
			this.finish();
		});
	}

	async startIntervalCapture() {
		this.capturedCount = 0;
		try {
			await this.capture();
		} catch (e) {
			console.error("capture failed", e);
			this.teardown();
		}
		this.intervalTimer = setInterval(async () => {
			try {
				await this.capture();
			} catch (e) {
				console.error("capture failed", e);
				this.teardown();
			}
			if (this.capturedCount >= this.totalShotsValue) {
				clearInterval(this.intervalTimer);
				await this.fetch();
			}
		}, this.intervalDurationValue);
	}

	async capture() {
		const blob = await this.captureFrame();
		this.capturedPhotos.push(blob);
		this.capturedCount++;
	}

	captureFrame() {
		const preview = this.previewTarget;
		const canvas = this.canvasTarget;
		const ctx = canvas.getContext("2d");

		const srcWidth = preview.videoHeight * (9 / 16);
		const srcHeight = srcWidth * (4 / 3);
		const sx = (preview.videoWidth - srcWidth) / 2;
		const sy = (preview.videoHeight - srcHeight) / 2;

		canvas.width = 300;
		canvas.height = 400;

		ctx.drawImage(preview, sx, sy, srcWidth, srcHeight, 0, 0, 300, 400);

		return new Promise((resolve) => {
			canvas.toBlob((blob) => resolve(blob), "image/jpeg", 0.8);
		});
	}

	async fetch() {
		const formData = new FormData();
		this.capturedPhotos.forEach((blob) => {
			formData.append("photos[]", blob);
		});

		try {
			const response = await fetch("/diagnoses", {
				method: "POST",
				body: formData,
				headers: {
					"X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
						.content,
				},
			});

			this.loaderTarget.classList.remove("hidden");

			if (response.ok) {
				const data = await response.json();
				this.aiDiagnosisTarget.textContent = data.content;
			} else {
				const data = await response.json();
				this.aiDiagnosisTarget.textContent = data.message;
			}
			this.aiDiagnosisTarget.classList.remove("hidden");
			this.loaderTarget.classList.add("hidden");
		} catch (e) {
			console.error("POST failed", e);
			this.teardown();
		}
	}

	async stop() {
		try {
			await this.interviewVideoTarget.pause();
			this.interviewVideoTarget.currentTime = 0;
		} catch (e) {
			console.error("Interview video not available", e);
			this.teardown();
		}
	}

	finish() {
		this.overlayTarget.classList.remove("hidden");
		this.messageTarget.textContent = "お疲れさまでした!";
		this.startButtonTarget.classList.add("hidden");
		this.resultButtonTarget.classList.remove("hidden");
		this.previewTarget.classList.add("hidden");
		this.teardown();
	}

	teardown() {
		clearTimeout(this.prepTimer);
		clearInterval(this.intervalTimer);
		this.stopCamera();
	}

	stopCamera() {
		const stream = this.previewTarget.srcObject;
		if (!stream) return;
		stream.getTracks().forEach((track) => {
			track.stop();
		});
		this.previewTarget.srcObject = null;
	}

	showFeedback() {
		this.interviewVideoTarget.classList.add("hidden");
		this.previewTarget.classList.add("hidden");
		this.resultButtonTarget.classList.add("hidden");
		this.messageTarget.classList.add("hidden");
		this.feedbackTarget.classList.remove("hidden");
		this.backToHomeButtonTarget.classList.remove("hidden");
	}

	reset() {
		this.feedbackTarget.classList.add("hidden");
		this.interviewVideoTarget.classList.remove("hidden");
		this.resultButtonTarget.classList.add("hidden");
		this.startButtonTarget.classList.remove("hidden");
		this.messageTarget.classList.remove("hidden");
		this.startButtonTarget.disabled = false;
		this.messageTarget.textContent =
			"準備ができたらスタートボタンを押してください。";
		this.overlayTarget.classList.remove("hidden");
		this.previewTarget.classList.remove("hidden");
		this.setVideo();
	}

	setVideo() {
		const selfIntroduction = "/videos/selfIntroduction.mp4";
		const applicationReason = "/videos/applicationReason.mp4";
		const strength = "/videos/strength.mp4";
		const videos = [selfIntroduction, applicationReason, strength];
		const index = Math.floor(Math.random() * 3);
		this.interviewVideoTarget.src = videos[index];
	}
}

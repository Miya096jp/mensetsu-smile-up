import { Controller } from "@hotwired/stimulus";
export default class extends Controller {
	static targets = ["lp", "cameraCheck", "guide", "diagnosis", "deviceError"];
	static outlets = ["camera-check", "diagnosis"];

	connect() {
		this.currentStep = this.lpTarget;
	}

	show(e) {
		this.switchTo(e.params.step);
	}

	async switchTo(step) {
		this.deviceErrorTarget.classList.add("hidden");
		const nextStep = this[`${step}Target`];
		if (step === "diagnosis") {
			try {
				await this.diagnosisOutlet.startCamera();
			} catch {
				this.currentStep.classList.add("hidden");
				this.deviceErrorTarget.classList.remove("hidden");
				return;
			}
			this.diagnosisOutlet.reset();
		}
		this.currentStep.classList.add("hidden");
		nextStep.classList.remove("hidden");
		this.currentStep = nextStep;
	}

	close() {
		this.currentStep.classList.add("hidden");
		this.lpTarget.classList.remove("hidden");
		this.currentStep = this.lpTarget;
		this.cameraCheckOutlet.stopCamera();
		this.diagnosisOutlet.stopCamera();
	}

	async startCamera(e) {
		try {
			await this[`${e.params.step}Outlet`].startCamera();
		} catch {
			this.deviceErrorTarget.classList.remove("hidden");
		}
	}

	async proceedFromCameraCheck() {
		this.cameraCheckOutlet.stopCamera();
		if (localStorage.saveKey === "checked") {
			try {
				await this.diagnosisOutlet.startCamera();
			} catch {
				this.deviceErrorTarget.classList.remove("hidden");
				return;
			}
			this.switchTo("diagnosis");
		} else {
			this.switchTo("guide");
		}
	}
}

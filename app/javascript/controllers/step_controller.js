import { Controller } from "@hotwired/stimulus";
export default class extends Controller {
  static targets = ["lp", "cameraCheck", "guide"]
  static outlets = ["camera-check"]

  connect() {
    this.currentStep = this.lpTarget
  }

  show(e) {
    const nextStep = this[`${e.params.step}Target`]
    nextStep.classList.remove("hidden")
    this.currentStep.classList.add("hidden")
    this.currentStep = nextStep
  }

  close() {
    this.currentStep.classList.add("hidden")
    this.lpTarget.classList.remove("hidden")
    this.currentStep = this.lpTarget
  }

  startCamera() {
    this.cameraCheckOutlet.startCamera()
  }

}

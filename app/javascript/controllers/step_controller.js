import { Controller } from "@hotwired/stimulus";
export default class extends Controller {
  static targets = ["lp", "cameraCheck"]
  static outlets = ["camera-check"]

  show(e) {
    this.currentStep = this[`${e.params.step}Target`]
    this.currentStep.classList.remove("hidden")
    this.lpTarget.classList.add("hidden")
  }

  close() {
    this.currentStep.classList.add("hidden")
    this.lpTarget.classList.remove("hidden")
  }

  startCamera() {
    this.cameraCheckOutlet.startCamera()
  }

}

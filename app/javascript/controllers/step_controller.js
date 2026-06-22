import { Controller } from "@hotwired/stimulus";
export default class extends Controller {
  static targets = ["lp", "cameraCheck", "guide", "diagnosis"]
  static outlets = ["camera-check", "diagnosis"]

  connect() {
    this.currentStep = this.lpTarget
  }

  show(e) {
    this.switchTo(e.params.step)
  }

  switchTo(step) {
    const nextStep = this[`${step}Target`]
    nextStep.classList.remove("hidden")
    this.currentStep.classList.add("hidden")
    this.currentStep = nextStep
  }

  close() {
    this.currentStep.classList.add("hidden")
    this.lpTarget.classList.remove("hidden")
    this.currentStep = this.lpTarget
  }

  startCamera(e) {
    this[`${e.params.step}Outlet`].startCamera()
  }

  proceedFromCameraCheck() {
    if (localStorage.saveKey === "checked") {
      this.switchTo("diagnosis")
      this.diagnosisOutlet.startCamera()
    } else {
      this.switchTo("guide")
    }
  }


}

import { Controller } from "@hotwired/stimulus";
export default class extends Controller {
  static targets = ["interviewVideo", "overlay", "message", "preview", "startButton", "resultButton"]

  async startCamera() {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        audio: false,
        video: true,
      });
      this.previewTarget.srcObject = stream;
      await this.previewTarget.play();
    } catch (e) {
      console.warn("Camera not available", e.message)
    }
  }

  async start() {
    try {
      this.overlayTarget.classList.add("hidden")
      this.messageTarget.textContent = "診断中..."
      this.startButtonTarget.disabled = true
      await this.interviewVideoTarget.play()

      this.interviewVideoTarget.addEventListener("ended", () => {
        this.finish()
      })
    } catch (e) {
      console.warn("Interview video not available", e.message)
    }
  }

  async stop() {
    try {
      await this.interviewVideoTarget.pause()
      this.interviewVideoTarget.currentTime = 1
    } catch (e) {
      console.warn("Interview video not available", e.message)
    }
  }

  finish() {
    this.overlayTarget.classList.remove("hidden")
    this.messageTarget.textContent = "お疲れさまでした!"
    this.startButtonTarget.classList.add("hidden")
    this.resultButtonTarget.classList.remove("hidden")
    this.previewTarget.classList.add("hidden")
    this.previewTarget.srcObject.getTracks().forEach(track => {
      track.stop();
    })

  }

  reset() {
    this.resultButtonTarget.classList.add("hidden")
    this.startButtonTarget.classList.remove("hidden")
    this.startButtonTarget.disabled = false
    this.messageTarget.textContent = "準備ができたらスタートボタンを押してください。"
    this.overlayTarget.classList.remove("hidden")
    this.previewTarget.classList.remove("hidden")
  }
}





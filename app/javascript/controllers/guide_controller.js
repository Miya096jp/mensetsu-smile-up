import { Controller } from "@hotwired/stimulus";
export default class extends Controller {
  static targets = ["checkBox"]

  check() {
    localStorage.clear();
    if (this.checkBoxTarget.checked) {
      localStorage.saveKey = "checked";
    }
  }
}

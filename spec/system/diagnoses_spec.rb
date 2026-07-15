require "rails_helper"

RSpec.describe "Diagnoses", type: :system do
  before do
    driven_by :rack_test
  end

  it "displays the top page" do
    visit root_path
    expect(page).to have_content "面接スマイルup!"
  end

  it "displays the start button" do
    visit root_path
    expect(page).to have_content "診断を始める"
    expect(page).to have_content "無料で診断してみる"
  end
end

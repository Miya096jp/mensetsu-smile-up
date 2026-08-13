require "rails_helper"

RSpec.describe DiagnosisRequest, type: :model do
  include ActionDispatch::TestProcess::FixtureFile

  it "is not valid with no jpeg images" do
    photos = []
    result = DiagnosisRequest.new(photos: photos)
    expect(result).not_to be_valid
    expect(result.errors[:photos]).to include("がありません")
  end

  it "is valid with two jpeg images" do
    photos = []
    2.times do
      photos << file_fixture_upload('photo.jpg', 'image/jpeg')
    end
    result = DiagnosisRequest.new(photos: photos)
    expect(result).to be_valid
  end

  it "is not valid with only one jpeg image" do
    photos = []
    photos << file_fixture_upload('photo.jpg', 'image/jpeg')
    result = DiagnosisRequest.new(photos: photos)
    expect(result).not_to be_valid
    expect(result.errors[:photos]).to include("の枚数が不正です")
  end

  it "is not valid with three jpeg images" do
    photos = []
    3.times do
      photos << file_fixture_upload('photo.jpg', 'image/jpeg')
    end
    result = DiagnosisRequest.new(photos: photos)
    expect(result).not_to be_valid
    expect(result.errors[:photos]).to include("の枚数が不正です")
  end

  it "is not valid with strings" do
    photos = [ "photo1", "photo2" ]
    result = DiagnosisRequest.new(photos: photos)
    expect(result).not_to be_valid
    expect(result.errors[:photos]).to include("のデータ形式が不正です")
  end

  it "is not valid with jpeg images larger than size limit" do
    stub_const("DiagnosisRequest::MAX_FILE_SIZE", 1)
    photos = []
    2.times do
      photos << file_fixture_upload('photo.jpg', 'image/jpeg')
    end
    result = DiagnosisRequest.new(photos: photos)
    expect(result).not_to be_valid
    expect(result.errors[:photos]).to include("のデータ容量が不正です")
  end
end

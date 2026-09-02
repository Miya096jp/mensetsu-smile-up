class DiagnosisRequest
  include ActiveModel::Model
  attr_accessor :photos

  validates :photos, presence: { message: "がありません" }
  validate :photos_must_be_array, :must_have_two_photos, :photos_must_be_jpeg, :photos_must_be_within_size_limit

  MAX_FILE_SIZE = 150.kilobytes

  private

  def photos_must_be_array
    errors.add(:photos, "は配列にしてください") if !photos.is_a?(Array)
  end

  def must_have_two_photos
    return if photos.blank? || !photos.is_a?(Array)
    errors.add(:photos, "の枚数が不正です") if photos.compact.size != 2
  end

  def photos_must_be_jpeg
    return if photos.blank? || !photos.is_a?(Array)
    photos.each do |photo|
      if photo.respond_to?(:tempfile)
        mime_type = Marcel::MimeType.for(photo.tempfile)
        mime_type != "image/jpeg" ? errors.add(:photos, "のデータ形式が不正です") : nil
      else
         errors.add(:photos, "のデータ形式が不正です")
      end
    end
  end

  def photos_must_be_within_size_limit
    return if photos.blank? || !photos.is_a?(Array)
    photos.each do |photo|
      return if !photo.respond_to?(:tempfile)
      errors.add(:photos, "のデータ容量が不正です") if photo.size >= MAX_FILE_SIZE
    end
  end
end

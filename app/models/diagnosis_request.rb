class DiagnosisRequest
  include ActiveModel::Model
  attr_accessor :photos

  validate :must_have_two_photos, :photos_must_be_jpeg, :photos_must_be_within_size_limit

  MAX_FILE_SIZE = 150.kilobytes

  private

  def must_have_two_photos
    errors.add(:photos, "の枚数が不正です") if photos.size != 2
  end

  def photos_must_be_jpeg
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
    photos.each do |photo|
      errors.add(:photos, "のデータ容量が不正です") if photo.size >= MAX_FILE_SIZE
    end
  end
end

class Micropost < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true
  validates :content, presence: true,
   length: {maximum: Settings.micropost.max_length}
  validate :picture_size

  scope :order_desc, ->{order created_at: :desc}

  mount_uploader :picture, PictureUploader

  private

  def picture_size
    return unless picture.size > Settings.picture.max_size
    errors.add :picture, t("message.pic_size")
  end
end

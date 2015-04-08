class ExternalProject < Project
  validates :name, :website, :one_liner, :cover_image, presence: true
  before_save :ensure_is_hidden

  def self.model_name
    Project.model_name
  end

  def ensure_is_hidden
    self.hide = true
  end
end
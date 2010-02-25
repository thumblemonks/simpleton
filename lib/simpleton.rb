class Simpleton
  Configuration = {}

  def self.configure
    yield Configuration
  end
end

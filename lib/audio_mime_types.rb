# frozen_string_literal: true

# Class AudioMimeTypes
class AudioMimeTypes
  def self.browser_playable?(mime_type)
    [Mime[:mp3], Mime[:ogg]].include? mime_type
  end

  def self.to_file_extension(mime_type)
    ".#{mime_type.to_sym}"
  end
end

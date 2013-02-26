class MediaAudioProperty < ActiveRecord::Base

  belongs_to :audio

  validates_numericality_of :sample_length
  validates_format_of :bitrate, :with => /^\d+k$/, :message => 'Invalid format. Example value 56k'
  

end

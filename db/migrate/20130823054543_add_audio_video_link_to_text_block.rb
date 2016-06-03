class AddAudioVideoLinkToTextBlock < ActiveRecord::Migration
  def change
    add_column :text_blocks, :audio_link, :string
    add_column :text_blocks, :video_link, :string
  end
end

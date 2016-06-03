class RemoveAudioVideoFromTextBlock < ActiveRecord::Migration
  def change 
    remove_column :text_blocks, :audio_link
    remove_column :text_blocks, :video_link
  end
end

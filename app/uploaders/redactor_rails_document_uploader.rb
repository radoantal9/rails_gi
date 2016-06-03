class RedactorRailsDocumentUploader < CarrierWave::Uploader::Base
  include RedactorRails::Backend::CarrierWave

  def store_dir
    "#{APP_CONFIG['uploads_dir']}/#{Rails.env}/redactor_assets/documents/#{model.id}"
  end

  def extension_white_list
    RedactorRails.document_file_types
  end
end

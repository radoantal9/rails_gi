class WordDefinitionsController < InheritedResources::Base
  load_and_authorize_resource

  respond_to :json
end

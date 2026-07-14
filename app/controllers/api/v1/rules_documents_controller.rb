module Api
  module V1
    class RulesDocumentsController < BaseController
      def index
        documents = RulesDocument.all
        return unless stale?(etag: documents, public: true)

        expires_in 1.hour, public: true
        render json: documents.map(&:as_json)
      end
    end
  end
end

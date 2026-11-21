# SPDX-License-Identifier: AGPL-3.0-or-later

module Api
  module V1
    class RulesDocumentsController < BaseController
      def index
        documents = RulesDocument.all
        return unless stale?(etag: documents)

        expires_in 1.hour
        render json: documents.map(&:as_json)
      end
    end
  end
end

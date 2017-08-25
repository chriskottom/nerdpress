require 'docraptor'

module NerdPress::Publishers
  class DocRaptor
    def initialize(config)
      @config = config
    end

    def publish(manuscript)
      ::DocRaptor.configure do |docraptor|
        docraptor.username = api_key
        # docraptor.debugging = test?
      end

      response = ::DocRaptor::DocApi.new.create_doc(
        test: test?,
        document_content: manuscript.to_html,
        name: document_name,
        document_type: "pdf"
      )

      deliverables_dir.mkpath unless deliverables_dir.exist?
      deliverable_file.write response
      deliverable_file
    end

    private

    def api_key
      @config.api_key
    end

    def test?
      !!@config.test
    end

    def document_name
      basename = @config.document_name
      if version = @config.version
        "#{ basename }-#{ version }.pdf"
      else
        "#{ basename }.pdf"
      end
    end

    def deliverables_dir
      @config.deliverables_path
    end

    def deliverable_file
      @config.deliverables_path.join(document_name)
    end
  end
end

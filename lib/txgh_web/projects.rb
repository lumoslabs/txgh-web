require 'yaml'

module TxghWeb
  class Projects
    class << self
      def all
        projects
      end

      def find_by_slug(slug)
        all.find { |p| p['slug'] == slug }
      end

      private

      def projects
        @projects ||= begin
          if ENV['PROJECTS_CONFIG']
            scheme, payload = split_uri(ENV['PROJECTS_CONFIG'])
            load_scheme(scheme, payload)
          else
            raise StandardError,
              'Project config not found. Set the PROJECTS_CONFIG environment variable.'
          end
        end
      end

      def load_scheme(scheme, payload)
        case scheme
          when 'file'
            load_file(payload)
          when 'raw'
            load_raw(payload)
          else
            raise StandardError, 'Invalid scheme for PROJECTS_CONFIG.'
        end
      end

      def load_file(file)
        load_raw(File.read(file))
      end

      def load_raw(raw)
        YAML.load(raw)
      end

      def split_uri(uri)
        if uri =~ /\A[\w]+:\/\//
          idx = uri.index('://')
          [uri[0...idx], uri[(idx + 3)..-1]]
        else
          [nil, uri]
        end
      end
    end
  end
end

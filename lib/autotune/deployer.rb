require 'uri'

module Autotune
  # Autotune blueprint base deployer
  class Deployer
    attr_accessor :base_url, :connect, :project
    attr_writer :logger

    # Create a new deployer
    def initialize(kwargs)
      kwargs.each do |k, v|
        send "#{k}=".to_sym, v
      end
    end

    # Deploy an entire directory
    def deploy(_source)
      raise NotImplementedError
    end

    # Deploy one file
    def deploy_file(_source, _path)
      raise NotImplementedError
    end

    # Hook for adjusting data and files before build
    def before_build(build_data, env)
      build_data['base_url'] = project_url
      build_data['asset_base_url'] = project_asset_url
    end

    # Hook to do stuff after a project is deleted
    def after_delete
      raise NotImplementedError
    end

    # Hook to do stuff after a project is moved (slug changed)
    def after_move
      raise NotImplementedError
    end

    # Get the url to a file
    def url_for(path)
      base = asset?(path) ? project_asset_url : project_url
      ret = [base, path].join('/')
      ret += '/' if File.extname(path).empty?
      ret
    end

    def deploy_path
      [parts.path, project.slug].join('/')
    end

    def project_url
      [base_url, project.slug].join('/')
    end

    def project_asset_url
      [try(:asset_base_url) || base_url, project.slug].join('/')
    end

    def logger
      @logger ||= Rails.logger
    end

    private

    # Get the parts of the connect url
    def parts
      @parts ||= URI.parse(connect)
    end

    def asset?(path)
      /\.html?$/.match(path).nil? && !/\..{1,5}$/.match(path).nil?
    end
  end
end

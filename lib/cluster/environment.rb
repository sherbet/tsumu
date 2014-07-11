module Cluster
  class Environment

    attr_accessor :name, :config, :group_name

    def initialize( args = {} )
      @name = args.fetch(:name, "development")
      @group_name = "dish-env-#{@name}"
      @config = YAML::load_file( PROJECT_ROOT.join("config/environments.yml" ))[@name]
    end

  end
end
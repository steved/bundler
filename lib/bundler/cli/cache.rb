module Bundler
  class CLI::Cache
    attr_reader :options
    def initialize(options)
      @options = options
    end

    def run
      Bundler.definition.validate_ruby!
      Bundler.definition.resolve_with_cache!
      setup_cache_all
      Bundler.settings[:no_copy_paths] = options["no-copy-paths"] if options.key?("no-copy-paths")
      Bundler.settings[:cache_all_platforms] = options["all-platforms"] if options.key?("all-platforms")
      Bundler.load.cache
      Bundler.settings[:no_prune] = true if options["no-prune"]
      Bundler.load.lock
    rescue GemNotFound => e
      Bundler.ui.error(e.message)
      Bundler.ui.warn "Run `bundle install` to install missing gems."
      exit 1
    end

  private

    def setup_cache_all
      Bundler.settings[:cache_all] = options[:all] if options.key?("all")

      if Bundler.definition.has_local_dependencies? && !Bundler.settings[:cache_all]
        Bundler.ui.warn "Your Gemfile contains path and git dependencies. If you want "    \
          "to package them as well, please pass the --all flag. This will be the default " \
          "on Bundler 2.0."
      end
    end
  end
end

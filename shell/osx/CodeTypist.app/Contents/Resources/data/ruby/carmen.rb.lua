return [=[
require 'yaml'
require 'pathname'

lib_path = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib_path)

require 'carmen/country'
require 'carmen/i18n'
require 'carmen/version'

module Carmen
  class << self

    attr_accessor :data_paths, :i18n_backend

    def data_paths
      @data_paths
    end

    def data_paths=(paths)
      @data_paths = paths
    end

    def i18n_backend
      @i18n_backend
    end

    def i18n_backend=(backend)
      @i18n_backend = backend
    end

    attr_accessor :root_path

    def append_data_path(path)
      World.instance.reset!
      self.data_paths << Pathname.new(path)
    end

    def clear_data_paths
      World.instance.reset!
      self.data_paths = []
    end

    def reset_data_paths
      clear_data_paths
      append_data_path(root_path + 'iso_data/base')
      append_data_path(root_path + 'iso_data/overlay')
    end

     def reset_i18n_backend
      base_locale_path = root_path + 'locale/base'
      override_locale_path = root_path + 'locale/overlay'
      self.i18n_backend = Carmen::I18n::Simple.new(base_locale_path,
                                                   override_locale_path)
    end
  end

  self.root_path = Pathname.new(__FILE__) + '../..'

  self.reset_data_paths
  self.reset_i18n_backend

end
]=]

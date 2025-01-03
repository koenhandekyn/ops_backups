module OpsBackups
  class Engine < ::Rails::Engine
    isolate_namespace OpsBackups

    initializer :append_migrations do |app|
      unless app.root.to_s.match? root.to_s
        app.config.paths["db/migrate"].concat(config.paths["db/migrate"].expanded)
      end
    end

    initializer :i18n do |app|
      app.config.i18n.load_path += Dir[root.join("config", "locales", "**", "*.{rb,yml}")]
    end
  end
end

require "open-uri"

module React
  module ServerRendering
    CLIENT_REQUIRE = %r{__webpack_require__\(.*webpack-dev-server\/client\/index\.js.*\n}

    # Get a compiled file from Webpacker
    class WebpackerManifestContainer
      def find_asset(logical_path)
        asset_path = Webpacker::Manifest.lookup(logical_path) # raises if not found
        if asset_path.start_with?("http")
          # this includes `webpack-dev-server/client/index.js` code which causes ExecJS to 💥
          dev_server_asset = open(asset_path).read
          dev_server_asset.sub!(CLIENT_REQUIRE, '//\0')
          dev_server_asset
        else
          full_path = File.join(
            # TODO: using `.parent` here won't work for nonstandard configurations
            Webpacker::Configuration.output_path.parent,
            asset_path
          )
          File.read(full_path)
        end
      end

      def self.compatible?
        !!defined?(Webpacker)
      end
    end
  end
end
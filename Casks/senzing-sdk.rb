cask "senzing-sdk" do
  version "4.0.0.25057"
  sha256 "0c4bd377fde5ad4c371e6d2f0a511927f31c60d46273c778cf50310faeb495f7"

  url "https://senzing-staging-osx.s3.amazonaws.com/senzingsdk_#{version}.pkg"

  name "Senzing SDK"
  desc "Senzing® Smarter Entity Resolution™ SDK with Entity Centric Learning™ technology. Connect Data. Power Intelligence.™ entity resolution."
  homepage "https://senzing.com"

  preflight do
    eula_env = ENV.fetch("HOMEBREW_SENZING_ACCEPT_EULA", "")
    if eula_env == "i_accept_the_senzing_eula"
      ohai "ENVIRONMENT SET TO ACKNOWLEDGE ACCEPTANCE of the Senzing EULA at https://senzing.com/end-user-license-agreement"
    else
      puts <<~EOS

        ════════════════════════════════════════════════════════════
        Senzing End User License Agreement
        https://senzing.com/end-user-license-agreement
        ════════════════════════════════════════════════════════════

        You must accept the Senzing EULA to install Senzing SDK.

        To accept non-interactively, set:
          HOMEBREW_SENZING_ACCEPT_EULA=i_accept_the_senzing_eula

      EOS
      print "Do you accept the license terms? [yes/no]: "
      response = $stdin.gets&.chomp&.downcase.to_s
      unless %w[y yes 1 true].include?(response)
        raise Cask::CaskError, "License not accepted. Installation aborted."
      end
    end

    # Write marker file so the PKG preinstall script knows the EULA was accepted.
    # sudo installer strips env vars, so we use a file to pass acceptance through.
    File.write("/tmp/.senzing_eula_accepted", "")
  end

  pkg "senzingsdk_#{version}.pkg"

  uninstall pkgutil: "com.senzing.sdk",
            delete:  ["/opt/senzing", "/opt/senzingsdk.pkg"]
end

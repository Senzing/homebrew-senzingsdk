# frozen_string_literal: true

cask "senzingsdk" do
  override_version = ENV["HOMEBREW_SENZING_SDK_VERSION"]

  if override_version && !override_version.empty?
    version override_version
    sha256 :no_check
  else
    version "4.3.0.26089"
    sha256 "87782fd834bb386c14c7b38d4e4bb783a2d20b28d6358cbabb86c8951568c75d"
  end

  url "https://senzing-staging-osx.s3.amazonaws.com/senzingsdk_#{version}.pkg"

  depends_on formula: "sqlite"
  depends_on formula: "openssl@3"

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
      unless $stdin.tty?
        ohai "No interactive terminal detected."
        puts <<~EOS

          To accept the Senzing EULA non-interactively, run:
            HOMEBREW_SENZING_ACCEPT_EULA=i_accept_the_senzing_eula brew install --cask senzingsdk

        EOS
        raise ::Cask::CaskError, "EULA acceptance required. See instructions above."
      end
      print "Do you accept the license terms? [yes/no]: "
      response = $stdin.gets&.chomp&.downcase.to_s
      unless %w[y yes 1 true].include?(response)
        raise ::Cask::CaskError, "License not accepted. Installation aborted."
      end
    end

    # Write marker file so the PKG preinstall script knows the EULA was accepted.
    # sudo installer strips env vars, so we use a file to pass acceptance through.
    File.write("/tmp/.senzing_eula_accepted", Time.now.to_i.to_s)
  end

  pkg "senzingsdk_#{version}.pkg"

  uninstall pkgutil: "com.senzing.sdk",
            delete:  ["/opt/senzing", "/opt/senzingsdk.pkg"]
end

# frozen_string_literal: true

cask "senzingsdk" do
  override_version = ENV["HOMEBREW_SENZING_SDK_VERSION"]

  if override_version && !override_version.empty?
    version override_version
    sha256 :no_check
  else
    version "4.3.2.26162"
    sha256 "6fbf9245ec7a6c80d508c78533ed23371be2f7fd1c76ef6e9ae07927f9d9b97f"
  end

  url "https://senzing-production-osx.s3.amazonaws.com/senzingsdk_#{version}.pkg"

  name "Senzing SDK"
  desc "Senzing® Smarter Entity Resolution™ SDK with Entity Centric Learning™ technology. Connect Data. Power Intelligence.™ entity resolution."
  homepage "https://senzing.com"

  depends_on macos: :ventura
  depends_on arch: :arm64
  depends_on formula: "sqlite"
  depends_on formula: "openssl@3"
  container type: :naked

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
  end

  stage_only true

  postflight do
    caskroom_version_dir = "#{HOMEBREW_PREFIX}/Caskroom/senzingsdk/#{version}"
    caskroom_senzing = "#{caskroom_version_dir}/senzing"
    symlink_path = "#{HOMEBREW_PREFIX}/opt/senzing"

    # Extract the .pkg as an archive — pkgutil unpacks without running installer
    # scripts; re-check them if upstream adds non-relocation setup work.
    pkg_file = "#{caskroom_version_dir}/senzingsdk_#{version}.pkg"
    raise ::Cask::CaskError, "Staged Senzing SDK .pkg not found at #{pkg_file}" unless File.exist?(pkg_file)

    expanded_dir = "#{caskroom_version_dir}/.pkg_expand"
    FileUtils.rm_rf(expanded_dir)
    system_command "/usr/sbin/pkgutil",
                   args:         ["--expand-full", pkg_file, expanded_dir],
                   must_succeed: true

    payload_senzing = "#{expanded_dir}/senzingsdk.pkg/Payload/senzing"
    unless Dir.exist?(payload_senzing)
      found = Dir.children(expanded_dir).sort.join(", ")
      raise ::Cask::CaskError,
            "No senzing/ directory found at #{payload_senzing}. " \
            "Top level contains: #{found}"
    end

    FileUtils.rm_rf(caskroom_senzing)
    FileUtils.mv(payload_senzing, caskroom_senzing)

    require "pathname"
    relative_target = Pathname.new(caskroom_senzing).relative_path_from(Pathname.new(symlink_path).parent)
    FileUtils.rm_f(symlink_path)
    FileUtils.ln_sf(relative_target.to_s, symlink_path)

    # Cleanup last so a rerun after mid-postflight failure can recover.
    FileUtils.rm_rf(expanded_dir)
    FileUtils.rm_f(pkg_file)
  end

  uninstall_postflight do
    symlink_path = "#{HOMEBREW_PREFIX}/opt/senzing"
    expected_target = "#{HOMEBREW_PREFIX}/Caskroom/senzingsdk/#{version}/senzing"

    # If upgrading, the symlink will already be updated to the new version, so don't delete it.
    if File.symlink?(symlink_path)
      target = File.expand_path(File.readlink(symlink_path), File.dirname(symlink_path))
      FileUtils.rm_f(symlink_path) if target == expected_target
    end
  end

  caveats <<~EOS
    The Senzing SDK has been installed to:
      #{HOMEBREW_PREFIX}/Caskroom/senzingsdk/#{version}/senzing

    A symlink has been created at:
      #{HOMEBREW_PREFIX}/opt/senzing

    Add these to your shell configuration (~/.zshrc or ~/.bash_profile):

      export SENZING_ROOT="#{HOMEBREW_PREFIX}/opt/senzing/er"
      export DYLD_LIBRARY_PATH="${SENZING_ROOT}/lib:$DYLD_LIBRARY_PATH"
      export PATH="${SENZING_ROOT}/bin:$PATH"

    Or source the provided setup script:
      source "#{HOMEBREW_PREFIX}/opt/senzing/er/setupEnv"
  EOS
end

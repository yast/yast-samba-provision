# encoding: utf-8

# ------------------------------------------------------------------------------
# Copyright (c) 2017 SUSE LINUX Products GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.
#
# Please submit bugfixes or comments via http://bugs.opensuse.org/
#
# ------------------------------------------------------------------------------

# File:	clients/samba-provision.ycp
# Package:	Configuration of samba-provision
# Summary:	Main file
# Authors:	Samuel Cabrero <scabrero@suse.com>
#
# Main file for samba configuration. Uses all other files.

module Yast

  class SambaProvisionClient < Client

    include Yast::Logger

    def main

      Yast.import "UI"

      textdomain "samba-provision"

      log.info("----------------------------------------")
      log.info("Samba-provision module started")

      Yast.import "CommandLine"
      Yast.include self, "samba-provision/wizards.rb"

      cmdline_description = {
        "id"         => "samba-provision",
        "help"       => _("Configuration of samba as Active Directory domain controller"),
        "guihandler" => fun_ref(method(:SambaProvisionSequence), "any ()")
      }

      ret = CommandLine.Run(cmdline_description)
      log.debug("ret=#{ret}")

      log.info("Samba-provision module finished")
      log.info("----------------------------------------")

      deep_copy(ret)

    end

  end

end

Yast::SambaProvisionClient.new.main

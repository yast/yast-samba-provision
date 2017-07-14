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
# Package:	Configuration of samba AD
# Summary:	Main file
# Authors:	Samuel Cabrero <scabrero@suse.com>

module Yast

  module SambaProvisionWizardsInclude

    def initialize_samba_provision_wizards(include_target)

      Yast.import "UI"

      textdomain "samba-provision"

      Yast.import "Sequencer"
      Yast.import "Wizard"

      Yast.include include_target, "samba-provision/dialogs.rb"

    end

    # Main workflow of the samba-server configuration
    # @return sequence result
    def MainSequence

      aliases = {
        "operation" => lambda { OperationDialog() },
        "options" => lambda { OptionsDialog() },
        "dns" => lambda { Dns() },
        "password" => lambda { Password() }
      }

      sequence = {
        "ws_start" => "operation",
        "operation" => { :abort => :abort, :next => "options" },
        "options"   => { :abort => :abort, :next => :finish }
      }

      ret = Sequencer.Run(aliases, sequence)

      deep_copy(ret)

    end

    # Whole configuration of samba-provision
    # @return sequence result
    def SambaProvisionSequence
      aliases = {
        "main" => lambda { MainSequence() },
        "write" => [ lambda { WriteDialog() }, true ]
      }

      sequence = {
        "ws_start" => "main",
        "main"     => { :abort => :abort, :next => :next },
        "write"    => { :abort => :abort, :next => :next }
      }

      Wizard.CreateDialog
      Wizard.SetDesktopTitleAndIcon("samba-provision")

      ret = Sequencer.Run(aliases, sequence)

      UI.CloseDialog
      deep_copy(ret)
    end

  end

end

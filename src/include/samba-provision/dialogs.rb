module Yast

  module SambaProvisionDialogsInclude

    def initialize_samba_provision_dialogs(include_target)

      Yast.import "UI"
      Yast.import "Label"
      Yast.import "CWM"
      Yast.import "Stage"
      Yast.import "Samba"

      textdomain "samba-provision"

      Yast.include include_target, "samba-provision/operation-widget.rb"
      Yast.include include_target, "samba-provision/options-widget.rb"
      Yast.include include_target, "samba-provision/additional-options-widget.rb"
      Yast.include include_target, "samba-provision/password-widget.rb"

    end

    # Operation dialog
    # @return `abort if aborted and `next otherwise
    def OperationDialog

      caption = _("Active Directory Domain Services Configuration Wizard")

      widget_descr = {
        "operation" => CreateSambaProvisionOperationWidget()
      }

      w = CWM.CreateWidgets(
        ["operation"],
        widget_descr
      )

      help = CWM.MergeHelps(w)
      contents = VBox("operation", VStretch())
      contents = CWM.PrepareDialog(contents, w)

      Wizard.SetContentsButtons(
        caption,
        contents,
        help,
        Label.BackButton,
        Label.NextButton
      )

      Wizard.SetAbortButton(:abort, Label.CancelButton)
      Wizard.HideBackButton

      ret = CWM.Run(
        w,
        { :abort => fun_ref(method(:confirmAbort), "boolean ()") }
      )

    end

    # Domain controller options dialog
    # @return `abort if aborted and `next otherwise
    def OptionsDialog

      caption = _("Domain Controller Options")

      widget_descr = {
        "options" => CreateSambaProvisionOptionsWidget()
      }

      w = CWM.CreateWidgets(
        ["options"],
        widget_descr
      )

      help = CWM.MergeHelps(w)
      contents = VBox("options", VStretch())
      contents = CWM.PrepareDialog(contents, w)

      Wizard.SetContentsButtons(
        caption,
        contents,
        help,
        Label.BackButton,
        Label.NextButton
      )

      Wizard.SetAbortButton(:abort, Label.CancelButton)

      ret = CWM.Run(
        w,
        { :abort => fun_ref(method(:confirmAbort), "boolean ()") }
      )

    end

    # Domain and computer netbios names dialog
    # @return `abort if aborted and `next otherwise
    def AdditionalOptionsDialog

      caption = _("Additional options")

      widget_descr = {
        "additional" => CreateSambaProvisionAdditionalOptionsWidget()
      }

      w = CWM.CreateWidgets(
        ["additional"],
        widget_descr
      )

      help = CWM.MergeHelps(w)
      contents = VBox("additional", VStretch())
      contents = CWM.PrepareDialog(contents, w)

      Wizard.SetContentsButtons(
        caption,
        contents,
        help,
        Label.BackButton,
        Label.NextButton
      )

      Wizard.SetAbortButton(:abort, Label.CancelButton)

      ret = CWM.Run(
        w,
        { :abort => fun_ref(method(:confirmAbort), "boolean ()") }
      )

      if ret == :next and SambaProvision.operation == "new_forest"
        ret = :adminpass
      end

      ret

    end

    # Password dialog
    # @return `abort if aborted and `next otherwise
    def PasswordDialog

      caption = _("Domain administrator password")

      widget_descr = {
        "password" => CreateSambaProvisionPasswordWidget()
      }

      w = CWM.CreateWidgets(
        ["password"],
        widget_descr
      )

      help = CWM.MergeHelps(w)
      contents = VBox("password", VStretch())
      contents = CWM.PrepareDialog(contents, w)

      Wizard.SetContentsButtons(
        caption,
        contents,
        help,
        Label.BackButton,
        Label.OKButton
      )

      Wizard.SetAbortButton(:abort, Label.CancelButton)

      ret = CWM.Run(
        w,
        { :abort => fun_ref(method(:confirmAbort), "boolean ()") }
      )

    end

    def ReadDialog

      Wizard.RestoreHelp(Ops.get_string(@HELPS, "read", ""))

      pkgs = [ "samba-ad-dc", "samba-dsdb-modules", "krb5-server" ]
      if !PackageSystem.CheckAndInstallPackagesInteractive(pkgs)
        Builtins.y2warning("packages not installed")
        return :abort
      end

      ret = Samba.Read
      ret ? :next : :abort

    end

    def WriteDialog

      Wizard.HideAbortButton
      Wizard.HideBackButton
      Wizard.HideNextButton
      ret = SambaProvision.Write
      ret ? :next : :abort

    end

    def confirmAbort

      Builtins.y2warning("confirm abort")

      Popup.ReallyAbort(true)

    end

  end

end

module Yast

  module SambaProvisionDialogsInclude

    def initialize_samba_provision_dialogs(include_target)

      Yast.import "UI"
      Yast.import "Label"
      Yast.import "CWM"

      textdomain "samba-provision"

      Yast.include include_target, "samba-provision/operation-widget.rb"
      Yast.include include_target, "samba-provision/options-widget.rb"

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
        Label.OKButton
      )

      Wizard.SetAbortButton(:abort, Label.CancelButton)

      ret = CWM.Run(
        w,
        { :abort => fun_ref(method(:confirmAbort), "boolean ()") }
      )

    end

    def confirmAbort

      Builtins.y2warning("confirm abort")

      Popup.ReallyAbort(true)

    end

  end

end

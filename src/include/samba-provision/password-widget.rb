module Yast

  module SambaProvisionPasswordWidgetInclude

    def initialize_samba_provision_password_widget(include_target)

      Yast.import "UI"
      Yast.import "SambaProvision"

      textdomain "samba-provision"

    end

    def CreateSambaProvisionPasswordWidget

      password_widget = VBox(
        VSpacing(1),
        Frame(
          _("Domain administrator password"),
          VBox(
            VSpacing(1),
            Password(Id(:passwd1), Opt(:hstretch, :notify), _("Administrator Password")),
            Password(Id(:passwd2), Opt(:hstretch, :notify), _("Administrator Password (Again)")),
            VSpacing(1),
            ReplacePoint(Id(:passwd_label), Label(""))
          )
        )
      )

      {
        "widget" => :custom,
        "custom_widget" => password_widget,
        "init"          => fun_ref(method(:SambaProvisionPasswordWidgetInit), "void (string)"),
        "handle"        => fun_ref(method(:SambaProvisionPasswordWidgetHandle), "symbol (string, map)"),
        "store"         => fun_ref(method(:SambaProvisionPasswordWidgetStore), "void (string, map)")
      }

    end

    def SambaProvisionPasswordWidgetInit(key)

    end

    def SambaProvisionPasswordWidgetHandle(key, event_descr)

      id = Ops.get(event_descr, "ID")

      if id == :passwd1 || id == :passwd2
        passwd1 = Convert.to_string(UI.QueryWidget(Id(:passwd1), :Value))
        passwd2 = Convert.to_string(UI.QueryWidget(Id(:passwd2), :Value))
        if passwd1 != passwd2
          UI.ReplaceWidget(
            Id(:passwd_label),
            Left(Label(_("Passwords do not match.")))
          )
        else
          UI.ReplaceWidget(
            Id(:passwd_label),
            Left(Label(_("Passwords match.")))
          )
        end
      end

      nil

    end

    def SambaProvisionPasswordWidgetStore(key, event_descr)

      passwd = Convert.to_string(UI.QueryWidget(Id(:passwd1), :Value))

      SambaProvision.admin_password = passwd

    end

  end

end

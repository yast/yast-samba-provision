module Yast

  module SambaProvisionOptionsWidgetInclude

    def initialize_samba_provision_options_widget(include_target)

      Yast.import "UI"
      Yast.import "SambaProvision"

      textdomain "samba-provision"

    end

    def CreateSambaProvisionOptionsWidget

      levels = [
        Item(Id("2003"), _("2003")),
        Item(Id("2008"),    _("2008")),
        Item(Id("2008_R2"), _("2008 R2"))
      ]

      dns_backends = [
        Item(Id("NONE"), _("None")),
        Item(Id("SAMBA_INTERNAL"), _("Samba internal"))
      ]

      options_widget = VBox(
        VSpacing(1),
        Frame(
          _("Select functional level of the new forest and root domain"),
          VBox(
            VSpacing(1),
            Left(ComboBox(Id(:forest_level), _("Forest and domain functional level"), levels)),
          )
        ),
        VSpacing(1),
        Frame(
          _("Specify domain controller capabilities"),
          VBox(
            VSpacing(1),
            Left(ComboBox(Id(:option_dns), _("DNS Server"), dns_backends)),
            Left(CheckBox(Id(:option_rodc), _("Read Only Domain Controller"))),
            Left(CheckBox(Id(:option_rfc2307), _("Store POSIX attributes in AD")))
          )
        )
      )

      {
        "widget" => :custom,
        "custom_widget" => options_widget,
        "init"          => fun_ref(method(:SambaProvisionOptionsWidgetInit),   "void (string)"),
        "handle"        => fun_ref(method(:SambaProvisionOptionsWidgetHandle), "symbol (string, map)"),
        "store"         => fun_ref(method(:SambaProvisionOptionsWidgetStore),  "void (string, map)")
      }

    end

    def SambaProvisionOptionsWidgetInit(key)

      UI.ChangeWidget(Id(:forest_level), :Value, Id("2008_R2"))

      case operation = SambaProvision.operation
      when "new_forest"
        UI.ChangeWidget(Id(:option_dns), :Enabled, true)
        UI.ChangeWidget(Id(:option_dns), :Value, Id("SAMBA_INTERNAL"))
        UI.ChangeWidget(Id(:option_rodc), :Enabled, false)
        UI.ChangeWidget(Id(:option_rodc), :Value, false)
        UI.ChangeWidget(Id(:option_rfc2307), :Enabled, true)
        UI.ChangeWidget(Id(:option_rfc2307), :Value, true)
      when "new_domain"
        UI.ChangeWidget(Id(:option_dns), :Enabled, true)
        UI.ChangeWidget(Id(:option_dns), :Value, Id("SAMBA_INTERNAL"))
        UI.ChangeWidget(Id(:option_rodc), :Enabled, false)
        UI.ChangeWidget(Id(:option_rodc), :Value, false)
        UI.ChangeWidget(Id(:option_rfc2307), :Enabled, false)
        UI.ChangeWidget(Id(:option_rfc2307), :Value, false)
      when "new_dc"
        UI.ChangeWidget(Id(:option_dns), :Enabled, true)
        UI.ChangeWidget(Id(:option_dns), :Value, Id("SAMBA_INTERNAL"))
        UI.ChangeWidget(Id(:option_rodc), :Enabled, true)
        UI.ChangeWidget(Id(:option_rodc), :Value, false)
        UI.ChangeWidget(Id(:option_rfc2307), :Enabled, false)
        UI.ChangeWidget(Id(:option_rfc2307), :Value, false)
      end

    end

    def SambaProvisionOptionsWidgetHandle(key, event_descr)

      nil

    end

    def SambaProvisionOptionsWidgetStore(key, event_descr)

      SambaProvision.forest_level = Convert.to_string(
        UI.QueryWidget(Id(:forest_level), :Value))

      SambaProvision.dns_backend = Convert.to_string(
        UI.QueryWidget(Id(:option_dns), :Value))

      SambaProvision.rodc = Convert.to_boolean(
        UI.QueryWidget(Id(:option_rodc), :Value))

      SambaProvision.rfc2307 = Convert.to_boolean(
        UI.QueryWidget(Id(:option_rfc2307), :Value))

    end

  end

end

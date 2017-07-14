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
        Item(Id("2008_R2"), _("2008 R2")),
        Item(Id("2012"), _("2012")),
        Item(Id("2012_R2"), _("2012 R2")),
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
            Left(CheckBox(Id(:option_dns), _("DNS Server"))),
            Left(CheckBox(Id(:option_gc), _("Global Catalog"))),
            Left(CheckBox(Id(:option_rodc), _("Read Only Domain Controller")))
          )
        )
      )

      {
        "widget" => :custom,
        "custom_widget" => options_widget,
        "init"          => fun_ref(method(:SambaProvisionOptionsWidgetInit), "void (string)"),
        "handle"        => fun_ref(method(:SambaProvisionOptionsWidgetHandle), "symbol (string, map)")
      }

    end

    def SambaProvisionOptionsWidgetInit(key)

      UI.ChangeWidget(Id(:forest_level), :Value, Id("2012_R2"))

      case operation = SambaProvision.operation
      when "new_forest"
        UI.ChangeWidget(Id(:option_dns), :Enabled, true)
        UI.ChangeWidget(Id(:option_dns), :Value, true)
        UI.ChangeWidget(Id(:option_gc), :Enabled, false)
        UI.ChangeWidget(Id(:option_gc), :Value, true)
        UI.ChangeWidget(Id(:option_rodc), :Enabled, false)
        UI.ChangeWidget(Id(:option_rodc), :Value, false)
      when "new_domain"
        UI.ChangeWidget(Id(:option_dns), :Enabled, true)
        UI.ChangeWidget(Id(:option_dns), :Value, true)
        UI.ChangeWidget(Id(:option_gc), :Enabled, true)
        UI.ChangeWidget(Id(:option_gc), :Value, true)
        UI.ChangeWidget(Id(:option_rodc), :Enabled, false)
        UI.ChangeWidget(Id(:option_rodc), :Value, false)
      when "new_dc"
        UI.ChangeWidget(Id(:option_dns), :Enabled, true)
        UI.ChangeWidget(Id(:option_dns), :Value, true)
        UI.ChangeWidget(Id(:option_gc), :Enabled, true)
        UI.ChangeWidget(Id(:option_gc), :Value, true)
        UI.ChangeWidget(Id(:option_rodc), :Enabled, true)
        UI.ChangeWidget(Id(:option_rodc), :Value, false)
      end

    end

    def SambaProvisionOptionsWidgetHandle(key, event_descr)

      nil

    end

  end

end

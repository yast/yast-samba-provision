module Yast

  module SambaProvisionAdditionalOptionsWidgetInclude

    def initialize_samba_provision_additional_options_widget(include_target)

      Yast.import "UI"
      Yast.import "SambaProvision"

      textdomain "samba-provision"

    end

    def CreateSambaProvisionAdditionalOptionsWidget

      additional_options_widget = VBox(
        VSpacing(1),
        Frame(
          _("NetBIOS names"),
          VBox(
            VSpacing(1),
            Left(InputField(Id(:netbios_domain_name), _("NetBIOS domain name"))),
            Left(InputField(Id(:netbios_host_name), _("NetBIOS host name")))
          )
        )
      )

      {
        "widget" => :custom,
        "custom_widget" => additional_options_widget,
        "init"          => fun_ref(method(:SambaProvisionAdditionalOptionsWidgetInit),   "void (string)"),
        "handle"        => fun_ref(method(:SambaProvisionAdditionalOptionsWidgetHandle), "symbol (string, map)"),
        "store"         => fun_ref(method(:SambaProvisionAdditionalOptionsWidgetStore),  "void (string, map)")
      }


    end

    def SambaProvisionAdditionalOptionsWidgetInit(key)

    end

    def SambaProvisionAdditionalOptionsWidgetHandle(key, event_descr)

      nil

    end

    def SambaProvisionAdditionalOptionsWidgetStore(key, event_descr)

      SambaConfig.GlobalSetStr("workgroup",
        Convert.to_string(
          UI.QueryWidget(Id(:netbios_domain_name), :Value)))

      SambaConfig.GlobalSetStr("netbios name",
        Convert.to_string(
          UI.QueryWidget(Id(:netbios_host_name), :Value)))

    end

  end

end

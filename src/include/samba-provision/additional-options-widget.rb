module Yast

  module SambaProvisionAdditionalOptionsWidgetInclude

    def initialize_samba_provision_additional_options_widget(include_target)

      Yast.import "UI"
      Yast.import "SambaProvision"
      Yast.import "Hostname"

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
        ),
        VSpacing(1),
        ReplacePoint(
          Id(:dns_options),
          VBox(VStretch())
        )
      )

      {
        "widget" => :custom,
        "custom_widget" => additional_options_widget,
        "init"          => fun_ref(method(:SambaProvisionAdditionalOptionsWidgetInit),
                                   "void (string)"),
        "handle"        => fun_ref(method(:SambaProvisionAdditionalOptionsWidgetHandle),
                                   "symbol (string, map)"),
        "store"         => fun_ref(method(:SambaProvisionAdditionalOptionsWidgetStore),
                                   "void (string, map)"),
        "validate_type" => :function,
        "validate_function" => fun_ref(method(:SambaProvisionAdditionalOptionsWidgetValidate),
                                       "boolean (string, map)")
      }

    end

    def SambaProvisionAdditionalOptionsWidgetInit(key)

      domain = SambaConfig.GlobalGetStr("realm", "").split('.')[0].upcase[0, 15]
      UI.ChangeWidget(Id(:netbios_domain_name), :Value, domain)

      hostname = Hostname.CurrentHostname.upcase[0, 15]
      UI.ChangeWidget(Id(:netbios_host_name), :Value, hostname)

      dns_backends = [
        Item(Id("SAMBA_INTERNAL"), _("Samba internal"))
      ]

      if SambaProvision.dns
        UI.ReplaceWidget(
          Id(:dns_options),
          Frame(
            _("DNS Server"),
            VBox(
              VSpacing(1),
              Left(ComboBox(Id(:dns_backend), _("Backend"), dns_backends)),
            )
          )
        )
        UI.ChangeWidget(Id(:dns_backend), :Value, Id("SAMBA_INTERNAL"))
      end

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

      SambaProvision.dns_backend = Convert.to_string(
        UI.QueryWidget(Id(:dns_backend), :Value))

    end

    def SambaProvisionAdditionalOptionsWidgetValidate(key, event_descr)

      domain_name = UI.QueryWidget(Id(:netbios_domain_name), :Value)
      host_name = UI.QueryWidget(Id(:netbios_host_name), :Value)

      if domain_name.length == 0 || domain_name.length > 15
        return false
      end

      # TODO Check domain name not in use

      if host_name.length == 0 || host_name.length > 15
        return false
      end

      # TODO Check host name not in use

      true

    end

  end

end

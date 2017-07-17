module Yast

  module SambaProvisionOperationWidgetInclude

    def initialize_samba_provision_operation_widget(include_target)

      Yast.import "UI"
      Yast.import "SambaProvision"

      textdomain "samba-provision"

    end

    def CreateSambaProvisionOperationWidget

      operation_widget = VBox(
        VSpacing(1),
        Frame(
          _("Deployment operation"),
          RadioButtonGroup(
            Id(:operation),
            VBox(
              VSpacing(1),
              Left(RadioButton(Id(:op_new_dc),     Opt(:notify), _("Add a domain controller to an existing domain"))),
              Left(RadioButton(Id(:op_new_domain), Opt(:notify), _("Add a new domain to an existing forest"))),
              Left(RadioButton(Id(:op_new_forest), Opt(:notify), _("Add a new forest"))),
            )
          ),
        ),
        VSpacing(1),
        ReplacePoint(
          Id(:operation_options),
          VBox(VStretch())
        ),
        VStretch()
      )

      {
        "widget" => :custom,
        "custom_widget" => operation_widget,
        "init"          => fun_ref(method(:SambaProvisionOperationWidgetInit), "void (string)"),
        "handle"        => fun_ref(method(:SambaProvisionOperationWidgetHandle), "symbol (string, map)"),
        "store"         => fun_ref(method(:SambaProvisionOperationWidgetStore), "void (string, map)")
      }

    end

    def SambaProvisionOperationWidgetInit(key)

      UI.ChangeWidget(
        Id(:op_new_forest),
        :Value,
        true
      )
      SambaProvisionOperationOptionsNewForest()

    end

    def SambaProvisionOperationWidgetHandle(key, event_descr)

      id = Ops.get(event_descr, "ID")

      if id == :op_new_dc
        SambaProvisionOperationOptionsNewDC()
      elsif id == :op_new_domain
        SambaProvisionOperationOptionsNewDomain()
      elsif id == :op_new_forest
        SambaProvisionOperationOptionsNewForest()
      end

      nil

    end

    def SambaProvisionOperationWidgetStore(key, event_descr)

      case operation = UI.QueryWidget(Id(:operation), :Value)
      when :op_new_forest
        SambaProvision.operation = "new_forest"
        SambaConfig.GlobalSetStr("realm",
          Convert.to_string(
            UI.QueryWidget(Id(:new_forest_name), :Value)))
      when :op_new_domain
        SambaProvision.operation = "new_domain"
        SambaConfig.GlobalSetStr("realm",
          Convert.to_string(
            UI.QueryWidget(Id(:new_domain_name), :Value)))
        SambaProvision.parent_domain_name =
          Convert.to_string(
            UI.QueryWidget(Id(:parent_domain_name), :Value))
      when :op_new_dc
        SambaProvision.operation = "new_dc"
	SambaConfig.GlobalSetStr("realm",
          Convert.to_string(
            UI.QueryWidget(Id(:domain_name), :Value)))
      else
        SambaProvision.operation = ""
        log.warning("Unhandled operation")
      end

    end

    def SambaProvisionOperationOptionsNewForest

      UI.ReplaceWidget(
        Id(:operation_options),
        Frame(
          _("Specify the domain information for this operation"),
          VBox(
            VSpacing(1),
            Left(InputField(Id(:new_forest_name), Opt(:hstretch), _("Root domain name")))
          )
        )
      )

    end

    def SambaProvisionOperationOptionsNewDomain

      UI.ReplaceWidget(
        Id(:operation_options),
        Frame(
          _("Specify the domain information for this operation"),
          VBox(
            VSpacing(1),
            Left(InputField(Id(:parent_domain_name), Opt(:hstretch), _("Parent domain name"))),
            Left(InputField(Id(:new_domain_name),    Opt(:hstretch), _("New domain name")))
          )
        )
      )

    end

    def SambaProvisionOperationOptionsNewDC

      UI.ReplaceWidget(
        Id(:operation_options),
        Frame(
          _("Specify the domain information for this operation"),
          VBox(
            VSpacing(1),
            Left(InputField(Id(:domain_name), Opt(:hstretch), _("Domain")))
          )
        )
      )

    end

  end

end

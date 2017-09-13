module Yast

  module SambaProvisionOperationWidgetInclude

    def initialize_samba_provision_operation_widget(include_target)

      Yast.import "UI"
      Yast.import "SambaProvision"
      Yast.import "Ldap"

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
        ReplacePoint(
          Id(:operation_credentials),
          VBox(VStretch())
        ),
        VStretch()
      )

      {
        "widget" => :custom,
        "custom_widget" => operation_widget,
        "init"          => fun_ref(method(:SambaProvisionOperationWidgetInit), "void (string)"),
        "handle"        => fun_ref(method(:SambaProvisionOperationWidgetHandle), "symbol (string, map)"),
        "store"         => fun_ref(method(:SambaProvisionOperationWidgetStore), "void (string, map)"),
        "validate_type" => :function,
        "validate_function" => fun_ref(method(:SambaProvisionOperationWidgetValidate), "boolean (string, map)")
      }

    end

    def SambaProvisionOperationWidgetInit(key)

      UI.ChangeWidget(Id(:op_new_forest), :Value, true)
      UI.ChangeWidget(Id(:op_new_domain), :Enabled, false)
      UI.ChangeWidget(Id(:op_new_dc), :Enabled, true)
      SambaProvisionOperationOptionsNewForest()

    end

    def SambaProvisionOperationWidgetHandle(key, event_descr)

      id = Ops.get(event_descr, "ID")

      if id == :op_new_dc
        SambaProvisionOperationOptionsNewDC()
        SambaProvisionOperationOptionsCredentials(true)
      elsif id == :op_new_domain
        SambaProvisionOperationOptionsNewDomain()
        SambaProvisionOperationOptionsCredentials(true)
      elsif id == :op_new_forest
        SambaProvisionOperationOptionsNewForest()
        SambaProvisionOperationOptionsCredentials(false)
      end

      nil

    end

    def SambaProvisionOperationWidgetStore(key, event_descr)

      case operation = UI.QueryWidget(Id(:operation), :Value)
      when :op_new_forest
        SambaProvision.operation = "new_forest"
        SambaConfig.GlobalSetStr("realm",
          Convert.to_string(
            UI.QueryWidget(Id(:new_forest_name), :Value)).upcase)
      when :op_new_domain
        SambaProvision.operation = "new_domain"
        SambaConfig.GlobalSetStr("realm",
          Convert.to_string(
            UI.QueryWidget(Id(:new_domain_name), :Value)).upcase)
        SambaProvision.parent_domain_name =
          Convert.to_string(
            UI.QueryWidget(Id(:parent_domain_name), :Value))
      when :op_new_dc
        SambaProvision.operation = "new_dc"
        SambaProvision.credentials_username =
          Convert.to_string(
            UI.QueryWidget(Id(:credentials_username), :Value))
        SambaProvision.credentials_password =
          Convert.to_string(
            UI.QueryWidget(Id(:credentials_password), :Value))
        SambaConfig.GlobalSetStr("realm",
          Convert.to_string(
            UI.QueryWidget(Id(:domain_name), :Value)).upcase)
      else
        SambaProvision.operation = ""
        log.warning("Unhandled operation")
      end

      SambaConfig.GlobalSetStr("server role", "domain controller")

    end

    def SambaProvisionOperationWidgetValidate(key, event_descr)

      case operation = UI.QueryWidget(Id(:operation), :Value)
      when :op_new_forest
        realm = Convert.to_string(
          UI.QueryWidget(Id(:new_forest_name), :Value))
        # TODO: Validate domain
        # TODO: Query DNS to check specified realm is not defined
        if realm.length == 0
          return false
        end
      # TODO: Validate new domain operation
      when :op_new_dc
        domain = Convert.to_string(
          UI.QueryWidget(Id(:domain_name), :Value))
        # TODO: Validate domain
        # TODO: Query DNS to check specified realm is defined
        if domain.length == 0
          return false
        end
        username = Convert.to_string(
          UI.QueryWidget(Id(:credentials_username), :Value))
        password = Convert.to_string(
          UI.QueryWidget(Id(:credentials_password), :Value))
        if username.length == 0 or password.length == 0
          return false
        end
        # TODO Query domain (net ads info) and get LDAP server
        # Check credentials binding to LDAP
        # TODO Check domain and forest functional level
      end

      true

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

    def SambaProvisionOperationOptionsCredentials(visible)

      if (visible)
        UI.ReplaceWidget(
          Id(:operation_credentials),
          Frame(
            _("Specify the credentials for this operation"),
            VBox(
              VSpacing(1),
              Left(InputField(Id(:credentials_username), Opt(:hstretch), _("Username"))),
              Left(Password(Id(:credentials_password), Opt(:hstretch), _("Password")))
            )
          )
        )
      else
        UI.ReplaceWidget(
          Id(:operation_credentials),
          VBox(VStretch())
        )
      end

    end

  end

end

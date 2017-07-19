require "yast"

module Yast

  class SambaProvisionClass < Module

    def main
      Yast.import "UI"

      textdomain "samba-provision"

      Yast.import "Message"
      Yast.import "Progress"
      Yast.import "SambaConfig"
      Yast.import "Kerberos"

      @operation = ""
      @parent_domain_name = ""

      @dns = true
      @rodc = false
      @rfc2307 = true

      @forest_level = "2008_R2"
      @dns_backend = "NONE"

      @admin_password = ""

    end

    def Write

      caption = _("Provisioning Samba Active Directory Domain controller...")

      no_stages = 3
      stages = [
        _("Write the settings"),
        _("Provision"),
        _("Write kerberos settings"),
      ]
      steps = [
        _("Writting the settings..."),
        _("Provisioning..."),
        _("Writting kerberos settings..."),
      ]

            Progress.New(caption, " ", no_stages, stages, steps, "")

      # Write settings
      Progress.NextStage

      if !set_role_dc
        Report.Error(Message.CannotWriteSettingsTo("/etc/samba/smb.conf"))
        return false
      end

      if !SambaConfig.Write(true)
        Report.Error(Message.CannotWriteSettingsTo("/etc/samba/smb.conf"))
        return false
      end

      # Provision
      Progress.NextStage

      if !write_provision
        Report.Error(_("Error provisioning database. Check logs for details."))
        return false
      end

      # Write krb
      Progress.NextStage
      if !write_kerberos
        Report.Error(Message.CannotWriteSettingsTo("/etc/krb5.conf"))
        return false
      end

      # Final stage
      Progress.NextStage

      true

    end

    def set_role_dc

      lcrealm = SambaConfig.GlobalGetStr("realm", "").downcase

      # Set netlogon share
      netlogon = {
        "path" => "/var/locks/sysvol/#{lcrealm}/scripts",
        "read only" => "No"
      }
      SambaConfig.ShareSetMap("netlogon", netlogon)

      # Set sysvol share
      sysvol = {
        "path" => "/var/locks/sysvol",
        "read only" => "No"
      }
      SambaConfig.ShareSetMap("sysvol", sysvol)

      # Set settings
      SambaConfig.GlobalSetStr("security", "AUTO")
      SambaConfig.GlobalSetStr("passdb backend", "samba_dsdb")
      SambaConfig.GlobalSetStr("map to guest", "Never")
      SambaConfig.GlobalSetStr("idmap backend", nil)

      true

    end

    def write_provision

      domain = SambaConfig.GlobalGetStr("workgroup", "")
      realm = SambaConfig.GlobalGetStr("realm", "")

      cmd = "samba-tool domain provision " +
            "--server-role=dc " +
            "--realm='#{realm}' " +
            "--domain='#{domain}' " +
            "--adminpass='#{@admin_password}' " +
            "--function-level='#{@forest_level}' " +
            "--dns-backend='#{@dns_backend}' "

      if @rfc2307
        cmd += " --use-rfc2307"
      end

      output = SCR.Execute(path(".target.bash_output"), cmd)
      Builtins.y2milestone("Samba provision result: #{output}")

      output["exit"] == 0

    end

    def write_kerberos

      realm = SambaConfig.GlobalGetStr("realm", "")

      new_cfg = {
        "pam_login" => {
          "use_kerberos" => false
        },
        "kerberos_client" => {
          "default_realm" => realm.upcase,
          "default_domain" => realm.downcase,
          "kdc_server" => "",
          "trusted_servers" => ""
        }
      }
      Kerberos.Read()
      Kerberos.Import(new_cfg)
      Kerberos.dns_used = true
      Kerberos.modified = true
      Kerberos.Write()

      true

    end

    publish variable: :operation, type: "string"
    publish variable: :parent_domain_name, type: "string"
    publish variable: :admin_password, type: "string"
    publish variable: :dns, type: "boolean"
    publish variable: :rodc, type: "boolean"
    publish variable: :rfc2307, type: "boolean"
    publish variable: :forest_level, type: "string"
    publish variable: :dns_backend, type: "string"

  end

  SambaProvision = SambaProvisionClass.new
  SambaProvision.main

end

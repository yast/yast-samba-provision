require "yast"

module Yast

  class SambaProvisionClass < Module

    def main
      Yast.import "UI"

      textdomain "samba-provision"

      Yast.import "Progress"
      Yast.import "SambaConfig"

      @operation = ""
      @parent_domain_name = ""

      @forest_level = ""
      @dns_backend = ""
      @rodc = false
      @rfc2307 = true

      @admin_password = ""

    end

    def Write

      caption = _("Provisioning Samba Active Directory Domain controller...")

      no_stages = 4
      stages = [
        _("Write the settings"),
        _("Provision"),
        _("Write kerberos settings"),
        _("Write dns settings")
      ]
      steps = [
        _("Writting the settings..."),
        _("Provisioning..."),
        _("Writting kerberos settings..."),
        _("Writting dns settings...")
      ]

      Progress.New(caption, " ", no_stages, stages, steps, "")

      # Write settings
      Progress.NextStage

      if !SambaConfig.Write(true)
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

      # Write dns
      Progress.NextStage

      # Final stage
      Progress.NextStage

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

    publish variable: :operation, type: "string"
    publish variable: :parent_domain_name, type: "string"
    publish variable: :admin_password, type: "string"
    publish variable: :forest_level, type: "string"
    publish variable: :dns_backend, type: "string"
    publish variable: :rodc, type: "boolean"
    publish variable: :rfc2307, type: "boolean"

  end

  SambaProvision = SambaProvisionClass.new
  SambaProvision.main

end

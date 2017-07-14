require "yast"

module Yast

  class SambaProvisionClass < Module

    def main

      @operation = ""
      @new_forest_name = ""
      @new_domain_name = ""
      @existing_domain_name = ""
      @parent_domain_name = ""

    end

    publish variable: :operation, type: "string"
    publish variable: :new_forest_name, type: "string"
    publish variable: :new_domain_name, type: "string"
    publish variable: :existing_domain_name, type: "string"
    publish variable: :parent_domain_name, type: "string"

  end

  SambaProvision = SambaProvisionClass.new
  SambaProvision.main

end

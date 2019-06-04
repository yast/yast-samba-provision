# Sources for samba-client

module_DATA = \
  modules/SambaProvision.rb \
  modules/SambaToolDomainAPI.py

client_DATA = \
  clients/samba-provision.rb

yncludedir = @yncludedir@/samba-provision
ynclude_DATA = \
  include/samba-provision/wizards.rb \
  include/samba-provision/dialogs.rb \
  include/samba-provision/additional-options-widget.rb \
  include/samba-provision/operation-widget.rb \
  include/samba-provision/options-widget.rb \
  include/samba-provision/password-widget.rb

scrconf_DATA =

agent_SCRIPTS =

schemafilesdir = $(schemadir)/autoyast/rnc
schemafiles_DATA =

desktop_DATA = \
  desktop/org.opensuse.yast.SambaProvision.desktop

EXTRA_DIST = $(module_DATA) $(client_DATA) $(ynclude_DATA) $(scrconf_DATA) $(agent_SCRIPTS) $(schemafiles_DATA) $(desktop_DATA)

include $(top_srcdir)/Makefile.am.common

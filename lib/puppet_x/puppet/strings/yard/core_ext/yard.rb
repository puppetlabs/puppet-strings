require 'yard'
require 'puppet_x/puppet/strings'

# Patch the regular expression used to match namespaces
# so it will allow namespace segments that begin with
# both uppercase and lowercase letters (i.e. both
# Puppet::Namespace and puppet::namespace)
YARD::CodeObjects.send(:remove_const, :CONSTANTMATCH)
YARD::CodeObjects::CONSTANTMATCH = /[a-zA-Z]\w*/

# This is a temporary hack until a new version of YARD is
# released. We submitted a patch to YARD to add the
# CONSTANTSTART constant so that we could patch it and
# successfully match our own namesapces. However until
# the next version of the YARD gem is released, we must
# patch the problematic method itself as it is not yet
# using the added variable
if defined? YARD::CodeObjects::CONSTANTSTART
  YARD::CodeObjects.send(:remove_const, :CONSTANTSTART)
  YARD::CodeObjects::CONSTANTSTART = /^[a-zA-Z]/
else
  class YARD::CodeObjects::Proxy
    def proxy_path
      if @namespace.root?
        (@imethod ? YARD::CodeObjects::ISEP : "") + name.to_s
      elsif @origname
        if @origname =~ /^[a-zA-Z]/
          @origname
        else
          [namespace.path, @origname].join
        end
      elsif name.to_s =~ /^[a-zA-Z]/ # const
        name.to_s
      else # class meth?
        [namespace.path, name.to_s].join(YARD::CodeObjects::CSEP)
      end
    end
  end
end

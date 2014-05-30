# TODO: This should be extendable. However, the re-assignment of
# @objects_by_letter prevents that. Submit a pull request.
def index
  @objects_by_letter = {}
  objects = Registry.all(:class, :module, :hostclass, :definedtype).sort_by {|o| o.name.to_s }
  objects = run_verifier(objects)
  objects.each {|o| (@objects_by_letter[o.name.to_s[0,1].upcase] ||= []) << o }
  erb(:index)
end

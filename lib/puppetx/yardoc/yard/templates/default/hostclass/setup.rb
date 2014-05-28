include T('default/module')

def init
  sections :header, :box_info, :pre_docstring, T('docstring'), :subclasses
end

def subclasses
  # The naming is a bit weird because Ruby classes use `globals.subclasses`.
  unless globals.hostsubclasses
    globals.hostsubclasses = {}
    list = run_verifier Registry.all(:hostclass)
    list.each {|o| (globals.hostsubclasses[o.parent_class.path] ||= []) << o if o.parent_class }
  end

  @subclasses = globals.hostsubclasses[object.path]

  return if @subclasses.nil? || @subclasses.empty?
  erb(:subclasses)
end

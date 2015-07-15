include T('default/definedtype')

def init
  super
  sections.push :subclasses

  @template_helper = TemplateHelper.new
  @template_helper.check_parameters_match_docs object
  params = object.parameters.map { |param| param.first }
  param_tags = object.tags.find_all{ |tag| tag.tag_name == "param"}
  param_details = @template_helper.extract_param_details(params, param_tags) unless params.nil?
  @template_helper.check_types_match_docs object, param_details
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


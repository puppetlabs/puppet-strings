include T('default/module')

def init
  sections :header, :box_info, :pre_docstring, T('docstring'),
    :method_summary, [:item_summary],
    :method_details_list, [T('method_details')]
end

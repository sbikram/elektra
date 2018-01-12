module ObjectStorage
  module ApplicationHelper

    def has_capability?(capability)
      services.object_storage.list_capabilities.has_key?(capability.to_s)
    end

    def make_breadcrumb(container_name, path='')
      # empty path?
      return [[], container_name] if path.gsub('/', '') == ''
      # first breadcrumb element is container name, linking to its root directory
      crumbs = [ link_to(container_name, plugin('object_storage').list_objects_path(container_name)) ]

      # make one crumb per path element
      elements = path.split('/').delete_if { |e| e.blank? }
      last_crumb = elements.pop
      elements.each_with_index do |name,idx|
        link = plugin('object_storage').list_objects_path(container_name, path: elements[0..idx].join('/'))
        crumbs << link_to(name, link)
      end

      return [crumbs, last_crumb]
    end

    def format_bytes(value_in_bytes)
      content_tag(:span, title: "#{value_in_bytes} bytes") { Core::DataType.new(:bytes).format(value_in_bytes) }
    end

  end
end

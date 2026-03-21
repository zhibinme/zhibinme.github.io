module Jekyll
  module CategoryLinkFilter
    def category_link(category_name)
      base_path = @context.registers[:site].config['category_base_path'] || ''
      slug = Utils.slugify(category_name)
      "#{base_path}/#{slug}/"
    end
  end
end

Liquid::Template.register_filter(Jekyll::CategoryLinkFilter)
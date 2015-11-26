module Template::TemplateHelper

  # language attribute
  def getLang()
    if(params[:locale])
      return params[:locale]
    else
      return I18n.default_locale
    end
  end

  # page field
  def get_field(field_name, page_id)
    if (field = Field.find_by(page_id: page_id, name: field_name))
      case field.type_field
      # image field
      when "image"
        return field.image
      # file field
      when "file"
        return field.file
      # repeater field
      when "repeater"
        objects = []
        if(field.value)
          objects_id = field.value.split(',')
          objects_id.each do |id|
            objects.push(field.repeating.capitalize.constantize.find(id))
          end
        end
        return objects
      # other field
      else
        if(params[:locale])
          return raw field.send("value_#{params[:locale]}")
        else
          return raw field.send("value_#{I18n.default_locale}")
        end
      end
    end
  end

end

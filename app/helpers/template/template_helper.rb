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
  def get_page_field(field_name, page_id)
    if (field = Field.find_by(page_id: page_id, name: field_name))
      case field.type_field
      # image field
      when "image"
        return Image.find(field.value)
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

  def get_type_field(field_name, field_type, type_object)
    if(type_object)
      case field_type
      # image field
      when "image"
        return Image.find(type_object.send(field_name))
      # other field
      else
        if(params[:locale])
          return raw type_object.send("#{field_name}_#{params[:locale]}")
        else
          return raw type_object.send("#{field_name}_#{I18n.default_locale}")
        end
      end
    end
  end

  

end

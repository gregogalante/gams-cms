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

  # type index object list
  def get_typeobjects()
    if(@type_objects)
      return @type_objects
    end
  end

  # type show object field
  def get_typefield(field_name, type_field)
    if(@type_object)
      case type_field
      # image field
      when "image"
        return @type_object.field_name
      # file field
      when "file"
        return @type_object.field_name
      else
        if(params[:locale])
          return raw @type_object.send("#{field_name}_#{params[:locale]}")
        else
          return raw @type_object.send("#{field_name}_#{I18n.default_locale}")
        end
      end
    end
  end

end

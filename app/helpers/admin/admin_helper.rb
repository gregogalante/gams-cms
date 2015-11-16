module Admin::AdminHelper

  # Return the call to the view of a field name if user is an administrator
  def putFieldName(field_name)
    if(session[:user_permissions] and session[:user_permissions] === 0)
      render 'layouts/admin/others/fieldname', field_name: field_name
    end
  end

  # Return the call to the right view of a field
  def getOutputField(field_name, page_id)
    field = Field.find_by(page_id: page_id, name: field_name)
    # get field value
    if(params[:locale])
      field_value = field.send("value_#{params[:locale]}")
    else
      field_value = field.value
    end

    case field.type_field
    # image field
    when "image"
      render 'layouts/admin/output/'+field.type_field, title: field.title, image: field.image
    # file field
    when "file"
      render 'layouts/admin/output/'+field.type_field, title: field.title, file: field.file
    # other field
    else
      render 'layouts/admin/output/'+field.type_field, title: field.title, value: field_value
    end
  end

  # Return the call to the right input tag of a field
  def getInputField(field_name, page_id, input_name)
    field = Field.find_by(page_id: page_id, name: field_name)

    case field.type_field
    # image field
    when "image"
      delete_url = admin_delete_field_attachment_path(field.id)
      render 'layouts/admin/input/'+field.type_field, title: field.title, image: field.image, name: input_name, delete_url: delete_url
    # file field
    when "file"
      delete_url = admin_delete_field_attachment_path(field.id)
      render 'layouts/admin/input/'+field.type_field, title: field.title, file: field.file, name: input_name, delete_url: delete_url
    # editor field
    when "editor"
      if(params[:locale])
        field_value = field.send("value_#{params[:locale]}")
      else
        field_value = field.value
      end
      render 'layouts/admin/input/'+field.type_field, title: field.title, value: field_value, name: input_name, unique_key: field.name
    # repeater field
    when "repeater"
      render 'layouts/admin/input/'+field.type_field, title: field.title, value: field.value, name: input_name, unique_key: field.name, repeating: field.repeating
    # other field
    else
      if(params[:locale])
        field_value = field.send("value_#{params[:locale]}")
      else
        field_value = field.value
      end
      render 'layouts/admin/input/'+field.type_field, title: field.title, value: field_value, name: input_name
    end
  end

  # Return the call to the right input tag of a typefield
  def getInputTypefield(field_name, type_id, type_name, input_name)
    if(!type_id.blank?)
      type = type_name.capitalize.constantize.find(type_id)
    else
      type = type_name.capitalize.constantize.new
    end
    # get metadata for the type
    type_metadata = Type.find_by(name: type_name)
    # get metadata for the field
    field_metadata = Typefield.find_by(name: field_name, type_id: type_metadata.id)

    case field_metadata.type_field
    # image field
    when "image"
      if(!type_id.blank?)
        delete_url = admin_delete_typefield_attachment_path(type_metadata.title,type_id,field_name)
      else
        delete_url = nil
      end
      render 'layouts/admin/input/'+field_metadata.type_field, title: field_metadata.title, image: type.send(field_name), name: input_name, delete_url: delete_url
    # file field
    when "file"
      if(!type_id.blank?)
        delete_url = admin_delete_typefield_attachment_path(type_metadata.title,type_id,field_name)
      else
        delete_url = nil
      end
      render 'layouts/admin/input/'+field_metadata.type_field, title: field_metadata.title, file: type.send(field_name), name: input_name, delete_url: delete_url
    # editor field
    when "editor"
      if(params[:locale])
        field_name = "#{field_name}_#{params[:locale]}"
      else
        field_name = "#{field_name}_#{I18n.default_locale}"
      end
      render 'layouts/admin/input/'+field_metadata.type_field, title: field_metadata.title, value: type.send(field_name), name: input_name, unique_key: field_metadata.name
    # other field
    else
      if(params[:locale])
        field_name = "#{field_name}_#{params[:locale]}"
      else
        field_name = "#{field_name}_#{I18n.default_locale}"
      end
      render 'layouts/admin/input/'+field_metadata.type_field, title: field_metadata.title, value: type.send(field_name), name: input_name
    end
  end

  # Return the call to the right output tag of a typefield
  def getOutputTypefield(field_name, type_id, type_name)
    type = type_name.capitalize.constantize.find(type_id)
    # get metadata for the type
    type_metadata = Type.find_by(name: type_name)
    # get metadata for the field
    field_metadata = Typefield.find_by(name: field_name, type_id: type_metadata.id)

    case field_metadata.type_field
    # image field
    when "image"
      render 'layouts/admin/output/'+field_metadata.type_field, title: field_metadata.title, image: type.send(field_name)
    # file field
    when "file"
      render 'layouts/admin/output/'+field_metadata.type_field, title: field_metadata.title, file: type.send(field_name)
    # editor field
    when "editor"
      if(params[:locale])
        field_name = "#{field_name}_#{params[:locale]}"
      else
        field_name = "#{field_name}_#{I18n.default_locale}"
      end
      render 'layouts/admin/output/'+field_metadata.type_field, title: field_metadata.title, value: type.send(field_name)
    else
      if(params[:locale])
        field_name = "#{field_name}_#{params[:locale]}"
      else
        field_name = "#{field_name}_#{I18n.default_locale}"
      end
      render 'layouts/admin/output/'+field_metadata.type_field, title: field_metadata.title, value: type.send(field_name)
    end
  end

  # Return a language selection code
  def getLanguageSelector
    if(params[:locale])
      # get data
      current_url = request.original_url
      languages_list = [I18n.default_locale] + $gams_config['languages_list']
      languages_url = []
      url = ""
      # create array with edited url
      languages_list.each do |language|
        before = 'locale='+params[:locale].to_s
        after = 'locale='+language.to_s
        url = current_url.gsub(before, after)
        languages_url.push(url)
      end
      # render partial layout
      render 'layouts/admin/others/languageselector', languages_list: languages_list, languages_url: languages_url
    end
  end

end
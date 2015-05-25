module Imagine
  module AttachmentHelper
    module FormBuilder
      # @see AttachmentHelper#attachment_field
      def attachment_field(method, options = {})
        self.multipart = true
        @template.attachment_field(@object_name, method, objectify_options(options))
      end
    end

    def attachment_url(record, name, *args, **opts)
      host = Imagine.display_host
      "#{host}/#{args[0]}/#{args[1]}x#{args[2]}/#{record.send("#{name}_id").to_sym}"
    end

    def attachment_field(object_name, method, object:, **options)
      options[:data] ||= {}

      attacher = object.send(:"#{method}_attacher")
      options[:accept] = attacher.accept

      if options[:direct]
        url = "#{Imagine.service_host}/#{Imagine.bucket}/upload"
        options[:data].merge!(direct: true, as: "file", url: url, host: Imagine.display_host)
      end

      html = hidden_field(object_name, method, value: attacher.data.to_json, object: object, id: nil)
      html + file_field(object_name, method, options)
    end

    def attachment_image_tag(record, name, *args, fallback: nil, format: nil, host: nil, **options)
      file = record && record.public_send("#{name}_id")
      classes = ["attachment", (record.class.model_name.singular if record), name, *options[:class]]

      if file
        image_tag(attachment_url(record, name, *args, format: format, host: host), options.merge(class: classes))
      elsif fallback
        classes << "fallback"
        image_tag(fallback, options.merge(class: classes))
      end
    end
  end
end

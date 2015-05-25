module Imagine
  module Attachment

    def attachment(name, raise_errors: true, type: nil, extension: nil, content_type: nil)
      mod = Module.new do
        attacher = :"#{name}_attacher"

        define_method attacher do
          ivar = :"@#{attacher}"
          instance_variable_get(ivar) or begin
            instance_variable_set(ivar, Attacher.new(self, name,
              raise_errors: raise_errors,
              extension: extension,
              content_type: content_type
            ))
          end
        end

        define_method "#{name}=" do |value|
          send(attacher).set(value)
        end

        define_method "#{name}_url=" do |url|
          send(attacher).download(url)
        end

        define_method name do
          send(attacher).get
        end

        define_method "remove_#{name}=" do |remove|
          send(attacher).remove = remove
        end

        define_method "remove_#{name}" do
          send(attacher).remove
        end

        define_singleton_method("to_s")    { "Imagine::Attachment(#{name})" }
        define_singleton_method("inspect") { "Imagine::Attachment(#{name})" }
      end

      include mod
    end
  end
end

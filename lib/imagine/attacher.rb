require "rest-client"
require "json"

module Imagine
  # @api private
  class Attacher
    attr_reader :record, :name, :options, :errors, :valid_extensions, :valid_content_types

    Presence = ->(val) { val if val != "" }

    def initialize(record, name, raise_errors: true, extension: nil, content_type: nil)
      @record = record
      @name = name
      @raise_errors = raise_errors
      @valid_extensions = [extension].flatten if extension
      @valid_content_types = [content_type].flatten if content_type
      @errors = []
      @metadata = {}
    end

    def id
      Presence[read(:id)]
    end

    def size
      Presence[@metadata[:size] || read(:size)]
    end

    def filename
      Presence[@metadata[:filename] || read(:filename)]
    end

    def content_type
      Presence[@metadata[:content_type] || read(:content_type)]
    end

    def cache_id
      Presence[@metadata[:id]]
    end

    def remove
      Presence[@metadata[:remove]]
    end

    def basename
      if filename and extension
        ::File.basename(filename, "." << extension)
      else
        filename
      end
    end

    def extension
      if filename
        Presence[::File.extname(filename).sub(/^\./, "")]
      elsif content_type
        type = MIME::Types[content_type][0]
        type.extensions[0] if type
      end
    end

    def get
      id
    end

    def set(value)
      if value.is_a?(String)
        retrieve!(value)
      else
        cache!(value)
      end
    end

    def retrieve!(value)
      @metadata = JSON.parse(value, symbolize_names: true) || {}
      write_metadata if cache_id
      remove! if remove?
    rescue JSON::ParserError
    end

    def cache!(uploadable)
      @metadata = {
        size: uploadable.size,
        content_type: Imagine.extract_content_type(uploadable),
        filename: Imagine.extract_filename(uploadable)
      }

      if valid?
        @metadata[:id] = upload(uploadable)
        write_metadata
      elsif @raise_errors
        raise Imagine::Invalid, @errors.join(", ")
      end
    end

    def download(url)
      return if url.to_s.empty?

      res = RestClient.post("#{Imagine.service_host}/#{Imagine.bucket}/url", url: url)
      res = JSON.parse(res)

      @metadata = {
        size: res['size'],
        content_type: res['format'],
        filename: res['filename']
      }

      if valid?
        @metadata[:id] = res['id']
        write_metadata
      elsif @raise_errors
        raise Imagine::Invalid, @errors.join(", ")
      end
    end

    def upload(uploadable)
      res = RestClient.post("#{Imagine.service_host}/#{Imagine.bucket}/upload", file: uploadable)
      JSON.parse(res)['id']
    end

    def remove!
      @record.destroy unless @record.new_record?
    end

    def store!
      if remove?
        delete!
        write(:id, nil)
      elsif cache_id
        write(:id, cache_id)
      end
      write_metadata
      @metadata = {}
    end

    def delete!
      # cache.delete(cache_id) if cache_id
      # store.delete(id) if id
      @metadata = {}
    end

    def accept
      if valid_content_types
        valid_content_types.join(",")
      elsif valid_extensions
        valid_extensions.map { |e| ".#{e}" }.join(",")
      end
    end

    def remove?
      remove and remove != "" and remove !~ /\A0|false$\z/
    end

    def present?
      not @metadata.empty?
    end

    def valid?
      @errors = []
      @errors << :invalid_extension if valid_extensions and not valid_extensions.include?(extension)
      @errors << :invalid_content_type if valid_content_types and not valid_content_types.include?(content_type)
      # @errors << :too_large if cache.max_size and size and size >= cache.max_size
      @errors.empty?
    end

    def data
      @metadata if valid?
    end

  private

    def read(column)
      m = "#{name}_#{column}"
      value ||= record.send(m) if record.respond_to?(m)
      value
    end

    def write(column, value)
      m = "#{name}_#{column}="
      record.send(m, value) if record.respond_to?(m) and not record.frozen?
    end

    def write_metadata
      write(:size, size)
      write(:content_type, content_type)
      write(:filename, filename)
    end
  end
end

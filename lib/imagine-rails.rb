module Imagine

  require "imagine/attacher"
  require "imagine/attachment"
  require "imagine/rails"

  class << self
    attr_accessor :service_host
    attr_accessor :display_host
    attr_accessor :bucket

    # Extract the content type from an uploadable object. If the content type
    # cannot be determined, this method will return `nil`.
    #
    # @param [IO] uploadable    The uploadable object to extract the content type from
    # @return [String, nil]     The extracted content type
    def extract_content_type(uploadable)
      if uploadable.respond_to?(:content_type)
        uploadable.content_type
      else
        filename = extract_filename(uploadable)
        if filename
          content_type = MIME::Types.of(filename).first
          content_type.to_s if content_type
        end
      end
    end

    # Extract the filename from an uploadable object. If the filename cannot be
    # determined, this method will return `nil`.
    #
    # @param [IO] uploadable    The uploadable object to extract the filename from
    # @return [String, nil]     The extracted filename
    def extract_filename(uploadable)
      path = if uploadable.respond_to?(:original_filename)
        uploadable.original_filename
      elsif uploadable.respond_to?(:path)
        uploadable.path
      end
      ::File.basename(path) if path
    end
  end

end

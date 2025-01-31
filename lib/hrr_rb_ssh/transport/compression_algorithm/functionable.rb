# coding: utf-8
# vim: et ts=2 sw=2

require 'zlib'
require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Transport
    class CompressionAlgorithm
      module Functionable
        def initialize direction
          @logger = Logger.new(self.class.name)
          case direction
          when Direction::OUTGOING
            @deflator = ::Zlib::Deflate.new
          when Direction::INCOMING
            @inflator = ::Zlib::Inflate.new
          end
        end

        def deflate data
          @deflator.deflate(data, ::Zlib::SYNC_FLUSH)
        end

        def inflate data
          @inflator.inflate(data)
        end

        def close
          @deflator.close if @deflator && @deflator.closed?.!
          @inflator.close if @inflator && @inflator.closed?.!
        end
      end
    end
  end
end

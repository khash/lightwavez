require File.join(File.expand_path(File.dirname(__FILE__)), "version")
require File.join(File.expand_path(File.dirname(__FILE__)), "client")
require 'yaml'

module Lightwavez

  class Controller

    def initialize(address = nil, port = 9760, mapping_file = "")
      @mapping = {}

      mapping_file = File.join(Dir.pwd, 'mapping.yml') if mapping_file == ""
      if File.exists? mapping_file
        @mapping = YAML.load_file(mapping_file)
      end

      @client = Lightwavez::Client.new(address, port)
    end

    def register
      @client.discover
    end

    def send(room, device, operation, params = {})
      room_id = get_room(room)['id']
      device_id = get_device(room, device)

      puts "Room: #{room_id}, Device: #{device_id}"

      pa = nil
      if operation == :mood
        pa = get_mood(room, params)

        puts "Mood: #{params}"
      else
        pa = params
      end

      cmd = @client.get_command(room_id, device_id, operation, pa)

      puts "Sending command #{cmd}"

      @client.send(cmd)
    end

    private

    def get_room(room)
      raise 'invalid mapping file. no "rooms" node found' unless @mapping.has_key? 'rooms'
      if @mapping['rooms'].has_key? room
        return @mapping['rooms'][room]
      else
        raise "invalid room name #{room}"
      end
    end

    def get_device(room, device)
      m_room = get_room(room)
      raise "invalid mapping format for room #{room}" unless m_room.has_key? 'devices'
      return m_room['devices'][device]
    end

    def get_mood(room, mood)
      m_room = get_room(room)
      raise "invalid mapping format for room #{room}" unless m_room.has_key? 'moods'
      return m_room['moods'][mood]
    end

  end

end

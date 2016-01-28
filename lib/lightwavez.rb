require File.join(File.expand_path(File.dirname(__FILE__)), "version")
require File.join(File.expand_path(File.dirname(__FILE__)), "client")
require 'yaml'

module Lightwavez

  # you will need to create one of these:
  # c = Lightwavez::Controller.new
  class Controller

    # if addres is missing, it will use discover to find it
    # if mapping_file is missing, it will load 'mapping.yml' from the running folder
    def initialize(address = nil, port = 9760, mapping_file = "")
      @mapping = {}

      mapping_file = File.join(Dir.pwd, 'mapping.yml') if mapping_file == ""
      if File.exists? mapping_file
        @mapping = YAML.load_file(mapping_file)
      end

      @client = Lightwavez::Client.new(address, port)
    end

    # registers the client with the link. The first time this runs the lights on the link
    # will flash and the button needs to be pressed to authorise the client
    # calling this again after initial registration will return the IP address of the link
    def register
      @client.discover
    end

    # sends a command to the link.
    # room is the name of the room based on mapping
    # device is the name of the device based on mapping. pass '' if the command doesn't need it (all_off and mood)
    # operation can be :on, :off, :all_off, :dim, :last_dim, :mood
    # params is used for dim (1-32) and mood (mood name based on mapping)
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

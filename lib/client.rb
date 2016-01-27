module Lightwavez

  require 'socket'

  class Client

    COMMANDS = { :on => 'F1', :off => 'F0', :all_off => 'Fa', :last_dim => 'Fo', :dim => 'Fd', :mood => 'Fm'}

    def initialize(address = nil, port = 9760)
      @address = address || discover
      @port = port
    end

    # generates a command for a room and a device. Only supports on/off/dimm commands for now
    # accepted operations are: :on, :off, :all_off, :last_dim, :dim (needs param to be 1-32), :mood (needs mood id)
    # device is not needed for :all_off and :mood
    # rooms, devices and moods (params for :mood) and be either a number or name if mapping is loaded
    def get_command(room, device, operation, params = nil)
      raise 'invalid command' unless COMMANDS.has_key? operation
      raise 'missing dim level (1-32)' if params.nil? && operation == :dim
      raise 'missing mood id' if params.nil? && operation == :mood

      cmd = ""
      if operation != :all_off && operation != :mood
        cmd = "R#{room}D#{device}#{COMMANDS[operation]}"
        if operation == :dim
          raise 'invalid dim level (1-32)' if params < 1 || params > 32
          cmd = cmd + "P#{params}"
        end
      else
        cmd = "R#{room}#{COMMANDS[operation]}"
        if operation == :mood
          cmd = cmd + "P#{params}"
        end
      end

      return cmd
    end

    # consructs and sends a command over to the link without waiting for the answer
    def send(command)
      sequence = Random.rand(100)
      send_raw("#{sequence},!#{command}\r")
    end

    # this will register the first time and get the IP address for the link afte that
    def discover
      sock = UDPSocket.new
      sock.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)

      result = ""
      server_thread = Thread.start do
        server = UDPSocket.open
        server.bind('0.0.0.0', 9761)
        result = server.recvfrom(64)
        server.close
      end

      sock.send("100,!F*p\r", 0, '255.255.255.255', 9760)
      server_thread.join
      sock.close

      if !result.is_a? Array || result.length < 1 || result[1].length < 2
        raise 'invalid response'
      end

      return result[1][2]
    end

    private

    # sends a command to the link without waiting for answer
    def send_raw(command)
      sock = UDPSocket.new
      sock.send(command, 0, @address, @port)
      sock.close
    end

  end

end

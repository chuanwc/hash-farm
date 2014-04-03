# -*- encoding : utf-8 -*-

module CoreExtensions
  refine Object do
    def boolean?
      self == !!self
    end
  end
  
  refine Integer do
    # intN.to_hex.hex => intN
    # ex : 285257.to_hex => "045a49"
    # ex : 2.to_hex(8) => "00000002"
    # ex : 300.to_hex(1) => "012c"
    # Warning with negative number :
    # ex : -100.to_hex(1) => "-64"
    # ex : -100.to_hex(2) => "-0064"
    def to_hex(nb_byte=1)
      raise ArgumentError, "negative nb_byte" if nb_byte < 0
      return "-" + (-self).to_hex(nb_byte) if self < 0
      s = "%0#{nb_byte*2}x" % self
      s = (s.size.odd? ? '0' : '') + s
      s
    end
  end

  refine String do
    # anHex.reverse_hex.reverse_hex => anHex +/- a leading 0
    # ex : "adbf986000000037".reverse_hex => "370000006098bfad"
    # ex : "-adbf986000000037".reverse_hex => "-370000006098bfad"
    def reverse_hex
      if self[0] == '-'
        '-' + ( self.size.even? ? self.insert(1,'0') : self ).scan(/\w{2}/).reverse.join
      else
        ( self.size.odd? ? '0'+self : self ).scan(/\w{2}/).reverse.join
      end
    end

    # ex : "adbf986000000037".to_bin => "\xAD\xBF\x98`\x00\x00\x007"
    def to_bin
      [self].pack("H*")
    end

    # ex : "\xAD\xBF\x98`\x00\x00\x007".to_hex => "adbf986000000037"
    def to_hex
      self.unpack("H*")[0]
    end

    # "1".hexsize => 1
    # "1f".hexsize => 1
    # "001f".hexsize => 2
    # "-1".hexsize => 1
    # "-1f".hexsize => 1
    # "-001f".hexsize => 2
    def hexsize
      ( ( self.size - ( self[0] == '-' ? 1 : 0 ) ) / 2.0 ).ceil
    end

    def hex?
      !! (self =~ /^-?[0-9a-f]+$/ || self =~ /^-?[0-9A-F]+$/)
    end

    def reverse_int_hex
      raise ArgumentError, "Hash must be 64 length" if self.size != 64
      self.scan(/\w{8}/).map { |h| h.reverse_hex }.join
    end

    def reverse_hash_int
      raise ArgumentError, "Hash must be 64 length" if self.size != 64
      self.scan(/\w{8}/).reverse.join
    end
  end

  refine Hash do
    def compact
      self.select { |_,v| v }
    end
  end

  refine OpenStruct do
    def delete( field )
      self.delete_field( field ) rescue nil
    end
  end
end

# module EventMachine
#   # Allows to safely run EM in foreground or in a background 
#   # regardless of is running already or not.
#   # 
#   # Foreground: EM::safe_run { ... }
#   # Background: EM::safe_run(:bg) { ... }
#   def EventMachine::safe_run(background = nil, &block)
#     if EventMachine::reactor_running?
#       # Attention: here we loose the ability to catch 
#       # immediate connection errors.
#       EventMachine::next_tick(&block)
#       sleep if $em_reactor_thread && !background
#     else
#       if background
#         $em_reactor_thread = Thread.new do
#           EventMachine::run(&block)
#         end
#         sleep( 0.01 ) while ! EventMachine::reactor_running?
#       else
#         EventMachine::run(&block)
#       end
#     end
#   end
# end
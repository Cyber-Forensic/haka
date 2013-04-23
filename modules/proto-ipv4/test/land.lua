
ipv4 = require('proto-ipv4')

return function(pkt)
    ip = ipv4(pkt)

    if ip.src == ip.dst then
        return packet.DENY
	else
		return packet.ACCEPT
    end
end

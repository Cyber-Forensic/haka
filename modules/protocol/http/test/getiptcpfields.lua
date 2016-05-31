-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

require("protocol/http")

haka.rule {
	on = haka.dissectors.http.events.request,
	eval = function (http, request)
		print(string.format("Ip source %s port source %s", http.flow.srcip, http.flow.srcport))
	end
}

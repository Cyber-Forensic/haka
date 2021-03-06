-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

TestRegexpModule = {}

local stream_data = { "bar fo", "o dea", "d beef", " cof", "fee", " foo foo " }

function TestRegexpModule:gen_stream(data, f)
	local stream = haka.vbuffer_stream()
	local manager = haka.vbuffer_stream_comanager:new(stream)
	manager:start(0, f)

	for i, d in ipairs(data) do
		local current = stream:push(haka.vbuffer_from(d))
		if i == #data then
			stream:finish()
		end

		manager:process_all(current)

		while stream:pop() do end
	end
end

function TestRegexpModule:setUp()
	local module = os.getenv("HAKA_MODULE")
	assert(module, "/!\\ TEST REQUIRES ENV VAR : HAKA_MODULE")
	self.rem = require("regexp/" .. module)
end

function TestRegexpModule:test_match_should_not_fail ()
	-- When
	local ret = self.rem.re:match(".*", "aaa")
	-- Then
	assertTrue(ret)
end

function TestRegexpModule:test_match_should_be_successful ()
	-- When
	local ret = self.rem.re:match(".*", "aaa")
	-- Then
	assertTrue(ret)
end

function TestRegexpModule:test_match_should_fail_when_pattern_do_not_match ()
	-- Given nothing
	-- When
	local ret = self.rem.re:match("abc", "aaa")
	-- Then
	assertIsNil(ret)
end

function TestRegexpModule:test_match_should_return_results ()
	-- Given nothing
	-- When
	local result = self.rem.re:match("bar", "foo bar foo")
	-- Then
	assertTrue(result)
end

function TestRegexpModule:test_match_should_return_nil_results_when_pattern_do_not_match ()
	-- Given nothing
	-- When
	local result = self.rem.re:match("bar", "foo")
	-- Then
	assertTrue(not result)
end

function TestRegexpModule:test_match_should_be_successful_using_new_escaping_char ()
	-- When
	local ret = self.rem.re:match("%d", "666")
	-- Then
	assertTrue(ret)
end

function TestRegexpModule:test_compile_should_not_fail ()
	-- When
	local ret, msg = self.rem.re:compile(".*")
	-- Then
	assertTrue(ret)
end

function TestRegexpModule:test_compile_should_be_successful ()
	-- When
	local re = self.rem.re:compile(".*")
	-- Then
	assertTrue(re)
end

function TestRegexpModule:test_compile_should_fail_with_bad_pattern ()
	-- When
	local ret, msg = pcall(function () self.rem.re:compile("?") end)
	-- Then
	assertFalse(ret)
end

function TestRegexpModule:test_compile_should_be_successful_using_new_escaping_char ()
	-- When
	local ret, msg = self.rem.re:compile("%d%s")
	-- Then
	assertTrue(ret)
end

function TestRegexpModule:test_exec_should_not_fail ()
	-- Given
	local re = self.rem.re:compile(".*")
	-- When
	local ret, msg = re:match("aaa")
	-- Then
	assertTrue(ret)
end

function TestRegexpModule:test_exec_should_be_successful ()
	-- Given
	local re = self.rem.re:compile(".*")
	-- When
	local ret = re:match("aaa")
	-- Then
	assertTrue(ret)
end

function TestRegexpModule:test_exec_should_fail_when_pattern_do_not_match ()
	-- Given
	local re = self.rem.re:compile("abc")
	-- When
	local ret = re:match("aaa")
	-- Then
	assertIsNil(ret)
end

function TestRegexpModule:test_exec_should_return_results ()
	-- Given
	local re = self.rem.re:compile("bar")
	-- When
	local result = re:match("foo bar foo")
	-- Then
	assertEquals(result, "bar")
end

function TestRegexpModule:test_exec_should_return_nil_results_when_pattern_do_not_match ()
	-- Given
	local re = self.rem.re:compile("bar")
	-- When
	local ret = re:match("foo")
	-- Then
	assertIsNil(ret)
end

function TestRegexpModule:test_create_sink_should_be_successful ()
	-- Given
	local re = self.rem.re:compile(".*")

	-- When
	local ret, msg = re:create_sink()

	-- Then
	assertTrue(ret)
end

function TestRegexpModule:test_feed_should_not_fail ()
	-- Given
	local re = self.rem.re:compile(".*")
	local sink = re:create_sink()
	-- When
	local ret, msg = sink:feed("aaa", true)
	-- Then
	assertTrue(ret)
end

function TestRegexpModule:test_feed_should_match_accross_two_string ()
	-- Given
	local re = self.rem.re:compile("ab")
	local sink = re:create_sink()
	-- When
	local ret = sink:feed("aaa")
	ret = sink:feed("bbb", true)
	-- Then
	assertTrue(ret)
end

function TestRegexpModule:test_feed_should_return_results ()
	-- Given
	local re = self.rem.re:compile("bar")
	local sink = re:create_sink()
	-- When
	local result = haka.regexp_result()
	local ret = sink:feed("foo bar foo", true, result)
	-- Then
	assertTrue(ret)
	assertEquals(result.first, 4)
	assertEquals(result.last, 7)
end

function TestRegexpModule:test_feed_should_return_invalid_results_when_pattern_do_not_match ()
	-- Given
	local re = self.rem.re:compile("bar")
	local sink = re:create_sink()
	-- When
	local result = haka.regexp_result()
	local ret = sink:feed("foo", true, result)
	-- Then
	assertFalse(ret)
	assertEquals(result.first, -1)
	assertEquals(result.last, -1)
end

function TestRegexpModule:test_feed_should_set_sink_to_partial ()
	-- Given
	local re = self.rem.re:compile("abc")
	local sink = re:create_sink()
	local ret = sink:feed("aaa", true)
	-- When
	local partial = sink:ispartial()
	-- Then
	assertTrue(partial)
end

function TestRegexpModule:test_match_should_not_match_different_case_without_option ()
	-- When
	local ret = self.rem.re:match("camel case", "CaMeL CaSe")
	-- Then
	assertIsNil(ret)
end

function TestRegexpModule:test_match_should_allow_case_insensitive ()
	-- When
	local ret = self.rem.re:match("camel case", "CaMeL CaSe", self.rem.re.CASE_INSENSITIVE)
	-- Then
	assertIsString(ret)
end

function TestRegexpModule:test_match_can_work_on_iterator ()
	-- Given
	local re = self.rem.re:compile("foo")
	local vbuf = haka.vbuffer_from("bar fo")
	vbuf:append(haka.vbuffer_from("o bar"))
	local iter = vbuf:pos("begin")
	-- When
	local ret = re:match(iter)
	-- Then
	assertTrue(ret)
end

function TestRegexpModule:test_match_on_iterator_should_return_a_subbuffer ()
	-- Given
	local re = self.rem.re:compile("foo")
	local vbuf = haka.vbuffer_from("bar fo")
	vbuf:append(haka.vbuffer_from("o bar"))
	local iter = vbuf:pos("begin")
	-- When
	local ret = re:match(iter, true)
	-- Then
	assertTrue(ret)
	assertEquals(ret:asstring(), 'foo')
end

function TestRegexpModule:test_can_match_twice_with_same_iterator ()
	-- Given
	local re = self.rem.re:compile("foo")
	local vbuf = haka.vbuffer_from("bar fo")
	vbuf:append(haka.vbuffer_from("o foo"))
	local iter = vbuf:pos("begin")
	local ret = re:match(iter, true)
	-- When
	local ret = re:match(iter, true)
	-- Then
	assertTrue(ret)
	assertEquals(ret:asstring(), 'foo')
end

function TestRegexpModule:test_can_match_on_blocking_iterator ()
	-- Given
	local re = self.rem.re:compile("foo")
	self:gen_stream(stream_data, function (iter)
		-- When
		local ret = re:match(iter, true)
		-- Then
		assertTrue(ret)
		assertEquals(ret:asstring(), 'foo')
	end)
end

function TestRegexpModule:test_can_match_on_blocking_iterator ()
	-- Given
	local re = self.rem.re:compile("foo")
	self:gen_stream(stream_data, function (iter)
		local ret
		local i = 0
		-- When
		repeat
			ret = re:match(iter)
			-- Then
			if ret then
				i = i + 1
			end
		until not ret
		assertEquals(i, 3)
	end)
end

function TestRegexpModule:test_can_match_on_blocking_iterator_with_sub_creation ()
	-- Given
	local re = self.rem.re:compile("foo")
	self:gen_stream(stream_data, function (iter)
		local ret
		local i = 0
		-- When
		repeat
			ret = re:match(iter, true)
			-- Then
			if ret then
				assertEquals(ret:asstring(), 'foo')
				i = i + 1
			end
		until not ret
		assertEquals(i, 3)
	end)
end

function TestRegexpModule:test_can_match_on_blocking_iterator_with_readonly_sub_creation ()
	-- Given
	local re = self.rem.re:compile("foo")
	self:gen_stream(stream_data, function (iter)
		local ret
		local i = 0
		-- When
		repeat
			ret = re:match(iter, true, true)
			-- Then
			if ret then
				assertEquals(ret:asstring(), 'foo')
				i = i + 1
			end
		until not ret
		assertEquals(i, 3)
	end)
end

function TestRegexpModule:test_can_match_on_blocking_iterator_partial_match_fail_follow_by_match ()
	-- Given
	local re = self.rem.re:compile("foo")
	self:gen_stream({"bar fo","b foo"}, function (iter)
		local ret
		local i = 0
		-- When
		repeat
			ret = re:match(iter, true, true)
			-- Then
			if ret then
				assertEquals(ret:asstring(), 'foo')
				i = i + 1
			end
		until not ret
		assertEquals(i, 1)
	end)
end

function TestRegexpModule:test_complexe_regexp ()
	-- Given
	local re = self.rem.re:compile("</?p( [^>]*)?>")
	local vbuf = haka.vbuffer_from("<pre><p>toto</p><p class=\"toto\">titi</p></pre>")
	local iter = vbuf:pos("begin")
	local ret
	local result = { "<p>", "</p>", "<p class=\"toto\">", "</p>" }
	local i = 0
	repeat
		-- When
		ret = re:match(iter, true)
		-- Then
		if ret then
			i = i + 1
			assertEquals(ret:asstring(), result[i])
		end
	until not ret
	assertEquals(i, 4)
end

addTestSuite('TestRegexpModule')

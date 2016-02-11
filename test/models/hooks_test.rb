#
# Bold - more than just blogging.
# Copyright (C) 2015-2016 Jens Krämer <jk@jkraemer.net>
#
# This file is part of Bold.
#
# Bold is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Bold is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Bold.  If not, see <http://www.gnu.org/licenses/>.
#
require 'test_helper'

class HooksTest < ActiveSupport::TestCase

  class TestHooks < ::Bold::Hooks::Listener
    def test_hook(context)
      context[:hook_caller].hook!
    end
  end

  class HookCaller
    include Bold::Hooks::Helper

    def hook_called?
      !!@hook_called
    end

    def hook!
      @hook_called = true
    end

    def do_something_with_hook
      call_hook :test_hook, object: self
    end

  end

  test 'should call hook with a block' do
    obj = HookCaller.new
    obj.do_something_with_hook
    assert obj.hook_called?
  end
end
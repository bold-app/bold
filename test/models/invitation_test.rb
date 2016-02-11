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

class InvitationTest < ActiveSupport::TestCase
  setup do
    Bold.current_site = create :site
  end

  test 'should have role values' do
    i = Invitation.new
    assert values = i.role_values
    assert_equal 2, values.size
  end

  test 'should have site values' do
    i = Invitation.new
    assert another_site = create(:site)
    assert values = i.site_values
    assert_equal 2, values.size
    assert values.detect{ |name, id| id == another_site.id }
  end

  test 'should invite new user to another site' do
  end

  test 'should invite new user' do
    i = Invitation.new email: 'user33@host.com', role: 'editor'
    assert i.valid?

    assert_difference 'SiteUser.count' do
      assert_difference 'User.count' do
        assert_enqueued_jobs 1 do
          assert i.create
        end
      end
    end

  end

end
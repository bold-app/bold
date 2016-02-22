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

module Frontend
  class ContactMessagesControllerTest < ActionController::TestCase

    setup do
      @page = create :published_page, template: 'contact_page'
    end

    test 'should validate message' do
      post :create, params: { path: @page.path, contact_message: {} }
      assert_response :success
      assert assigns(:contact_message).errors.present?
      assert_select '.has-error', /blank/
    end

    test 'should create message' do
      assert_difference 'ContactMessage.count' do
        post :create, params: {
          path: @page.path,
          contact_message: { sender_name: Faker::Name.name,
                             sender_email: Faker::Internet.email,
                             subject: 'test test',
                             body: Faker::Lorem.paragraph }
        }
      end
      assert_redirected_to content_url(@page.path)
    end
  end

end

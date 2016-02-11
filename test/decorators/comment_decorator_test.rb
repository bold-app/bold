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

class CommentDecoratorTest < Draper::TestCase

  setup do
    Bold.current_site = @site = create :site
    @post = create :published_post
    @site.update_attribute :post_comments, 'enabled'
    Rails.application.config.action_controller.asset_host = 'http://test.host'
  end

  test 'should generate gravatar url' do
    c = CommentDecorator.decorate create(:comment, post: @post, author_email: 'user@host.com')

    assert_equal %{<img width="64" height="64" alt="" class="avatar" src="https://secure.gravatar.com/avatar/10468ad8d146df7dc85e4f8c51ef542e?d=http%3A%2F%2Ftest.host%2Fassets%2Fbold%2Fdefault_avatar-b049fdf65622eaacddd537e45072b28b413672c09b466573427358fb8967a038.png&amp;s=128" />}, c.author_image(size: 64)
  end

  test 'should sanitize author_website' do

    %w(foo.bar www.foo.bar).each do |url|
      c = CommentDecorator.decorate create(:comment, post: @post, author_website: url)
      assert_equal %{<a rel="nofollow" href="http://#{url}">#{c.author_name}</a>}, c.author
    end

    %w(http://foo.bar https://foo.bar).each do |url|
      c = CommentDecorator.decorate create(:comment, post: @post, author_website: url)
      assert_equal %{<a rel="nofollow" href="#{url}">#{c.author_name}</a>}, c.author
    end

    [
      %{javascript:"alert('bla');"},
      %{" onclick="alert('bla');"}
    ].each do |url|
      c = CommentDecorator.decorate create(:comment, post: @post, author_website: url)
      assert_equal %{<a rel="nofollow" href="http://#{URI.escape url}">#{c.author_name}</a>}, c.author
    end
  end

end
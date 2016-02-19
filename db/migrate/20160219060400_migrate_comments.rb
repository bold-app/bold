class OldComment < ActiveRecord::Base
  self.table_name = 'comments'
end

class MigrateComments < ActiveRecord::Migration
  def up
    OldComment.all.each do |c|
      p = Comment.new(
        site_id: c.site_id,
        content_id: c.post_id,
        author_name: c.author_name,
        author_email: c.author_email,
        author_website: c.author_website,
        body: c.body,
        request: c.request,
        status: c.status,
        author_ip: c.author_ip
      )
      p.save validate: false
      p.update_columns created_at: c.comment_date, updated_at: c.updated_at
    end
  end
end

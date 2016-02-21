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
module Draftable

  def self.prepended(clazz)
    clazz.class_eval do
      has_one :draft
      scope :with_draft, ->{ joins(:draft) }
    end
  end

  def load_draft!
    draft.apply_changes_to self if has_draft?
  end

  def delete_draft!
    if draft
      draft.destroy
    end
  end

  def save_without_draft(*args)
    opts = args.extract_options!
    opts[:draft] = false
    args << opts
    save(*args)
  end

  def save(*args)
    opts = args.extract_options!
    draft = opts.delete :draft
    args << opts
    if false == draft
      super
    else
      transaction do
        opts = args.clone.extract_options!
        if published? && opts[:context] != :publish
          if changed?
            valid? # trigger validations
            errors.clear
            save_draft
            touch # bump up updated_at (and make sure after_save hooks get triggered even if we only saved the draft)
          end
          super
        elsif result = super
          delete_draft
          result
        end
      end
    end
  end

  def has_draft?
    draft.present?
  end

  def delete_draft
    draft.destroy if has_draft?
  end

  def save_draft
    draft = self.draft || Draft.new
    draft.take_changes_from self
    save_without_draft(validate: false) if new_record?
    (self.draft = draft).save
  end

end

# Creates a new site.
#
# Along with the site itself, several default pages and a default navigation
# are created. The current user, if present, is added as a manager to the new
# site.
class CreateSite < ApplicationAction

  Result = ImmutableStruct.new(:site_created?, :error_message)

  def initialize(new_site)
    @site = new_site
  end

  def call
    error = nil

    Site.transaction do

      add_current_user_as_manager

      unless @site.save
        error = I18n.t('actions.create_site.site_not_saved')
        raise ActiveRecord::Rollback
      end

      unless create_default_content
        error = I18n.t('actions.create_site.create_content_failed')
        raise ActiveRecord::Rollback
      end

      unless create_navigation
        error = I18n.t('actions.create_site.create_navigation_failed')
        raise ActiveRecord::Rollback
      end

      return Result.new site_created: true

    end

    Result.new site_created: false, error_message: error
  end

  private

  def add_current_user_as_manager
    if user = Bold.current_user
      @site.site_users.build user: user, manager: true
    end
  end


  def create_default_content
    theme = @site.theme
    if p = create_page_with_template(I18n.t('bold.content.page_title.homepage'),
                                     theme.homepage_template
                                    )
      @site.homepage_id = p.id
    end
    if p = create_page_with_template(I18n.t('bold.content.page_title.notfound'),
                                     theme.find_template(:not_found),
                                     body: I18n.t('bold.content.page_body.notfound')
                                    )
      @site.notfound_page_id = p.id
    end
    if p = create_page_with_template(I18n.t('bold.content.page_title.error'),
                                     theme.find_template(:error),
                                     body: I18n.t('bold.content.page_body.error')
                                    )
      @site.error_page_id = p.id
    end
    if p = create_page_with_template(I18n.t('bold.content.page_title.tag'),
                                     theme.find_template(:tag)
                                    )
      @site.tag_page_id = p.id
    end
    if p = create_page_with_template(I18n.t('bold.content.page_title.category'),
                                     theme.find_template(:category)
                                    )
      @site.category_page_id = p.id
    end
    if p = create_page_with_template(I18n.t('bold.content.page_title.author'),
                                     theme.find_template(:author)
                                    )
      @site.author_page_id = p.id
    end
    if p = create_page_with_template(I18n.t('bold.content.page_title.archive'),
                                     theme.find_template(:archive)
                                    )
      @site.archive_page_id = p.id
    end
    if p = create_page_with_template(I18n.t('bold.content.page_title.search'),
                                     theme.find_template(:search)
                                    )
      CreatePermalink.call p, p.permalink_path_args
      @site.search_page_id = p.id
    end
    @site.save
  end

  def create_navigation
    @site.navigations.create name: I18n.t('bold.content.navigation.home'),
                             url: @site.external_url
  end

  # Creates a page with the given title, template and body.
  #
  # Pages created this way have no Permalink attached, which means they
  # cannot be reached directly through a public URL. Search pages are the
  # notable exception.
  #
  # FIXME this is not ideal as it hides errors during page creation.
  def create_page_with_template(title, template, body: nil)
    return if template.nil?

    Page.new(title: title,
             template: template.name,
             site: @site,
             author: User.current,
             body: body).tap do |page|

      page.publish
      page.save
    end
  end

end

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
module Bold
  class AssetsController < SiteController
    rescue_from ActionController::MissingFile, with: :handle_missing_file

    prepend_before_action :find_asset, only: %i(pick edit update show destroy)
    site_object :asset

    decorate_assigned :asset, with: 'Bold::AssetDecorator'


    def index
      @asset_search = AssetSearch.new asset_search_params
      assets = current_site.assets.order('created_at DESC').page(params[:page]).per(18)
      @assets = @asset_search.present? ? @asset_search.search(assets) : assets
    end

    def new
      @source = params[:source] || 'upload'
      head 404 and return unless valid_source? @source
    end

    BUILTIN_SOURCES = %w(upload url).freeze
    def valid_source?(source)
      BUILTIN_SOURCES.include? source
    end

    def pick
    end

    def edit
    end

    def update
      @success = @asset.update_attributes(asset_params)
    end

    def show
      @asset.ensure_version! params[:version]
      send_file @asset.diskfile_path(params[:version]), disposition: :inline
    end

    def create_from_url
      @asset = current_site.assets.build new_asset_params(key: :remote_file_url)
      if @asset.save
        redirect_to new_bold_site_asset_url(current_site, source: 'url'), notice: 'bold.assets.from_url.success'
      else
        @source = 'url'
        flash[:alert] = 'bold.assets.from_url.failure'
        render 'new'
      end
    end

    def create
      @asset = current_site.assets.build new_asset_params
      if @asset.save
        respond_to do |format|
          format.html {
            render :json => [@asset.to_jq_upload].to_json,
            :content_type => 'text/html',
            :layout => false
          }
          format.json {
            render :json => { :files => [@asset.to_jq_upload] }
          }
        end
      else
        render :json => [{:error => "otherFailure"}], :status => 304
      end
    end

    def destroy
      @asset.destroy
      respond_to do |format|
        format.json { render json: true }
        format.html { redirect_to bold_site_assets_path(current_site) }
      end
    end

    def bulk_destroy
      @ids = params[:ids].to_s.split(',').reject(&:blank?)
      current_site.assets.where(id: @ids).destroy_all
    end

    private

    def asset_search_params
      params[:asset_search].permit :query, :content_type if params[:asset_search]
    end

    def find_asset
      @asset = Asset.find params[:id]
    end

    def asset_params
      params.require(:asset).permit :file, :title, :caption, :tag_list, :attribution, :original_url, :remote_file_url
    end

    def new_asset_params(key: :file)
      params.require(:asset).tap do |attributes|
        if key == :file
          attributes[:file] = attributes[:file].first if Array === attributes[:file]
        end
        #attributes.delete(:content_id) if attributes[:content_id].blank?
      #end.permit(:file, :content_id, :remote_file_url)
      end.permit(key)
    end

  end
end

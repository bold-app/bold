# search config creation for english
class SetupTsearch < ActiveRecord::Migration
  def up
    enable_extension 'unaccent'
    execute Bold::Search.sql_for_language_config 'english'
    execute %{update sites set config = config || hstore('tsearch_config', 'bold_english')}
  end

  def down
    execute "drop text search configuation bold_english"
  end
end
